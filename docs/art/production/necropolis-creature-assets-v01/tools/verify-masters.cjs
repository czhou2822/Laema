const { fs, path, root, sharp, sha, json, alphaBounds } = require('./lib.cjs');
const inventory = JSON.parse(fs.readFileSync(path.join(root, 'source-inventory.json'), 'utf8'));
const errors = [], warnings = [], entries = [];
async function main() {
  const hashes = new Set();
  for (const r of inventory.roster) {
    const dir = path.join(root, r.slug), mf = path.join(dir, 'master-manifest.json');
    if (!fs.existsSync(mf)) { warnings.push(r.name + ': master not produced yet'); continue; }
    const m = JSON.parse(fs.readFileSync(mf, 'utf8')), j = JSON.parse(fs.readFileSync(path.join(dir, 'job.json'), 'utf8'));
    const sourcePath = path.join(dir, m.source), mirrorPath = path.join(dir, m.mirror), highPath = path.join(dir, m.high_res_master);
    const source = fs.readFileSync(sourcePath), mirror = fs.readFileSync(mirrorPath), high = fs.readFileSync(highPath);
    if (sha(source) !== m.source_sha256 || sha(mirror) !== m.mirror_sha256 || sha(high) !== m.high_res_sha256) errors.push(r.name + ': output hash mismatch');
    if (hashes.has(m.high_res_sha256)) errors.push(r.name + ': duplicate master');
    hashes.add(m.high_res_sha256);
    for (const [label, png] of [['source', source], ['mirror', mirror]]) {
      const pm = await sharp(png).metadata(), b = await alphaBounds(png, 0);
      if (pm.width !== 1024 || pm.height !== 768 || !pm.hasAlpha) errors.push(r.name + ': ' + label + ' geometry/alpha');
      if (b.left < 40 || b.top < 40 || b.right > 984 || b.bottom > 728 || !b.transparent_pixels) errors.push(r.name + ': ' + label + ' transparent padding');
    }
    const a = await sharp(source).ensureAlpha().raw().toBuffer(), b = await sharp(mirror).ensureAlpha().raw().toBuffer();
    let mirrorExact = true;
    for (let y = 0; y < 768 && mirrorExact; y++) for (let x = 0; x < 1024 && mirrorExact; x++) for (let c = 0; c < 4; c++) {
      if (a[(y * 1024 + x) * 4 + c] !== b[(y * 1024 + 1023 - x) * 4 + c]) { mirrorExact = false; break; }
    }
    if (!mirrorExact) errors.push(r.name + ': mirror pixels differ');
    if (m.original_def_sha256 !== j.original_def_sha256 || m.source_metadata_sha256 !== j.source_metadata_sha256) errors.push(r.name + ': source identity mismatch');
    if (JSON.stringify(m.anchor) !== '[512,512]' || m.source_scale !== 180 / 73) errors.push(r.name + ': shared registration mismatch');
    if (!fs.existsSync(path.join(dir, 'report.md')) || !fs.existsSync(path.join(dir, 'visual-review.json'))) warnings.push(r.name + ': worker visual report pending');
    entries.push({ number: r.number, name: r.name, slug: r.slug, source_sha256: sha(source), mirror_sha256: sha(mirror), high_res_sha256: sha(high), high_res_dimensions: { width: (await sharp(high).metadata()).width, height: (await sharp(high).metadata()).height }, alpha_bounds: await alphaBounds(source, 64), exact_mirror: mirrorExact, uniform_scale_registration: m.registration, source_identity_matches_job: m.original_def_sha256 === j.original_def_sha256 });
  }
  const htmlPath = path.join(root, 'review.html'); let checkedLinks = 0;
  if (fs.existsSync(htmlPath)) {
    const html = fs.readFileSync(htmlPath, 'utf8');
    for (const match of html.matchAll(/(?:href|src)="([^"#]+)"/g)) {
      const p = path.resolve(root, match[1]); checkedLinks++;
      if (!p.startsWith(root + path.sep) || !fs.existsSync(p)) errors.push('Review link missing/outside package: ' + match[1]);
    }
  }
  const sourceVerification = JSON.parse(fs.readFileSync(path.join(root, 'source-verification.json'), 'utf8'));
  if (sourceVerification.failures.length) errors.push('Source verification not clean');
  const parentReview = JSON.parse(fs.readFileSync(path.join(root, 'parent-review.json'), 'utf8'));
  if (parentReview.entries.length !== 14) errors.push('Parent visual review incomplete');
  for (const e of entries) {
    const review = parentReview.entries.find(p => p.slug === e.slug);
    if (!review || review.source_sha256 !== e.source_sha256 || review.high_res_sha256 !== e.high_res_sha256 || review.comparison_sha256 !== sha(fs.readFileSync(path.join(root, e.slug, 'source-vs-master.png')))) errors.push(e.name + ': parent review is stale');
  }
  const production = JSON.parse(fs.readFileSync(path.join(root, 'production-status.json'), 'utf8'));
  if (production.entries.length !== 14 || new Set(production.entries.map(e => e.agent_id)).size !== 14 || production.entries.some(e => e.status !== 'complete-master-awaiting-approval') || !production.all_workers_finished_and_closed) errors.push('Dedicated worker accounting incomplete');
  for (const ref of JSON.parse(fs.readFileSync(path.join(root, 'references/benchmarks.json'), 'utf8'))) {
    if (sha(fs.readFileSync(path.join(root, ref.file))) !== ref.sha256) errors.push('Approved benchmark changed: ' + ref.file);
  }
  const complete = entries.length === 14 && !errors.length && !warnings.length;
  const report = { phase: 'static master approval gate', mechanical_checks_passed: complete, checked_masters: entries.length, distinct_master_hashes: hashes.size, checked_review_links: checkedLinks, cell: [1024, 768], anchor: [512, 512], source_groups: inventory.total_groups, source_timeline_positions: inventory.total_timeline_frames, entries, errors, warnings, checked_at: new Date().toISOString(), limits: ['File checks do not establish visual fidelity, anatomy or user approval.', 'Parent visual observations are recorded separately in parent-review.json.', 'No animation generation, engine import, editor, gameplay or runtime validation.', 'Original game timing and rights clearance remain unestablished.'] };
  json(path.join(root, 'master-validation.json'), report);
  console.log(JSON.stringify({ masters: entries.length, complete, errors, warnings, checked_review_links: checkedLinks }));
  if (errors.length) process.exitCode = 1;
}
main().catch(e => { console.error(e); process.exitCode = 1; });
