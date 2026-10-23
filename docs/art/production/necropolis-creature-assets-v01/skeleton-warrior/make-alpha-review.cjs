const { root, sharp, fs, path, json, sha } = require('../tools/lib.cjs');

async function main() {
  const dir = path.join(root, 'skeleton-warrior');
  const manifest = JSON.parse(fs.readFileSync(path.join(dir, 'master-manifest.json'), 'utf8'));
  const master = fs.readFileSync(path.join(dir, 'master_rgba.png'));
  const detail = await sharp(master).resize({ height: 480 }).png().toBuffer();
  const detailMeta = await sharp(detail).metadata();
  const scale = await sharp(master).resize(manifest.registration.width, manifest.registration.height).png().toBuffer();
  const panes = [];
  for (const [index, color] of ['#f0ede6', '#64717b', '#14212c'].entries()) {
    const background = await sharp({ create: { width: 340, height: 800, channels: 4, background: color } }).png().toBuffer();
    panes.push({ input: background, left: index * 340, top: 0 });
    panes.push({ input: detail, left: index * 340 + Math.round((340 - detailMeta.width) / 2), top: 30 });
    panes.push({ input: scale, left: index * 340 + Math.round((340 - manifest.registration.width) / 2), top: 558 });
  }
  await sharp({ create: { width: 1020, height: 800, channels: 4, background: '#00000000' } }).composite(panes).png().toFile(path.join(dir, 'alpha-review.png'));
  const rawPath = path.join(dir, 'raw/generated-attempt-03.png');
  const rawMeta = await sharp(rawPath).metadata();
  const raw = await sharp(rawPath).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let zero = 0, partial = 0, opaque = 0;
  for (let i = 3; i < raw.data.length; i += 4) {
    if (raw.data[i] === 0) zero++;
    else if (raw.data[i] === 255) opaque++;
    else partial++;
  }
  const masterMeta = await sharp(master).metadata();
  const sourceInspection = JSON.parse(fs.readFileSync(path.join(dir, 'source-inspection.json'), 'utf8'));
  const evidence = {
    purpose: 'mechanical image inventory and alpha inspection support; not game tests or runtime validation',
    selected_raw: 'raw/generated-attempt-03.png',
    raw_dimensions: [rawMeta.width, rawMeta.height],
    raw_has_alpha: rawMeta.hasAlpha,
    raw_alpha_pixel_counts: { zero, partial, opaque },
    raw_sha256: sha(fs.readFileSync(rawPath)),
    master_dimensions: [masterMeta.width, masterMeta.height],
    master_sha256: sha(master),
    source_dimensions: manifest.cell,
    actual_registered_bounds_alpha64: manifest.actual_registered_bounds,
    exact_mirror_verified_by_registration_helper: manifest.exact_mirror_verified,
    source_metadata_hash_matches_job: sourceInspection.source_metadata_hash_matches_job,
    source_def_hash_matches_job: sourceInspection.source_original_hash_matches_job,
    source_native_groups_exactly_match_job: sourceInspection.native_groups_exactly_match_job,
    alpha_review: 'alpha-review.png',
    alpha_review_backgrounds: ['light warm gray', 'mid cool gray', 'dark blue-gray'],
    alpha_review_top_visible_height: 480,
    alpha_review_bottom_visible_height: manifest.registration.height,
  };
  json(path.join(dir, 'mechanical-review.json'), evidence);
  console.log(JSON.stringify(evidence, null, 2));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
