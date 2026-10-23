const { fs, path, root, sharp, sha, job, json, alphaBounds, cropRect, label, registerMaster } = require('../tools/lib.cjs');
const dir = __dirname;
const attempt = process.argv[2] || '06';
if (!/^\d{2}$/.test(attempt)) throw Error('Expected two-digit attempt number');
const rawName = `raw-master-${attempt}.png`;
const input = path.join(dir, rawName);
const requestName = `request-master-${attempt}.json`;
const request = JSON.parse(fs.readFileSync(path.join(dir, requestName), 'utf8'));
const provenanceName = `provenance-master-${attempt}.json`;
const provenance = JSON.parse(fs.readFileSync(path.join(dir, provenanceName), 'utf8'));
const fileRecord = p => ({ path: path.relative(dir, p).replaceAll('\\', '/'), sha256: sha(fs.readFileSync(p)) });

async function main() {
  const j = job('black-knight');
  const nativeMetaPath = path.resolve(root, j.source_metadata);
  const defPath = path.resolve(root, j.original_def);
  const nativeMeta = JSON.parse(fs.readFileSync(nativeMetaPath, 'utf8'));
  const sourceChecks = {
    metadata_sha256: sha(fs.readFileSync(nativeMetaPath)),
    def_sha256: sha(fs.readFileSync(defPath)),
    idle_sha256: sha(fs.readFileSync(path.join(dir, 'native-idle.png'))),
    complete_group_metadata_matches_job: JSON.stringify(nativeMeta.groups) === JSON.stringify(j.groups.map(g => g.native)),
    groups: nativeMeta.groups.length,
    timeline_positions: nativeMeta.frame_count,
    distinct_indexed_drawings: new Set(nativeMeta.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size,
  };
  if (sourceChecks.metadata_sha256 !== j.source_metadata_sha256 || sourceChecks.def_sha256 !== j.original_def_sha256 || sourceChecks.idle_sha256 !== j.source_idle_frame_sha256 || !sourceChecks.complete_group_metadata_matches_job) throw Error('Source evidence changed');
  const referenceFiles = [path.join(dir, 'job.json'), path.resolve(root, 'worker-brief.md'), path.resolve(root, 'tools/lib.cjs'), nativeMetaPath, defPath,
    ...j.reference_images.map(f => path.join(dir, f)), ...j.native_group_guides.map(f => path.resolve(root, f)), path.resolve(dir, j.benchmark)];
  const completeProvenance = {
    ...provenance,
    selected_raw: rawName,
    selected_raw_sha256: sha(fs.readFileSync(input)),
    exact_request: fileRecord(path.join(dir, requestName)),
    exact_prompt: fileRecord(path.join(dir, `prompt-master-${attempt}.txt`)),
    reference_images: request.referenced_image_paths.map(fileRecord),
    preservation_inputs: referenceFiles.map(fileRecord),
    source_verification: sourceChecks,
  };
  const attemptHistory = [];
  for (let n = 1; n <= Number(attempt); n++) {
    const id = String(n).padStart(2, '0');
    const p = JSON.parse(fs.readFileSync(path.join(dir, `provenance-master-${id}.json`), 'utf8'));
    const r = JSON.parse(fs.readFileSync(path.join(dir, `request-master-${id}.json`), 'utf8'));
    const raw = path.join(dir, `raw-master-${id}.png`);
    const rawHash = sha(fs.readFileSync(raw));
    const originalHash = sha(fs.readFileSync(p.original_generated_path));
    if (rawHash !== originalHash || (p.original_generated_sha256 && rawHash !== p.original_generated_sha256)) throw Error(`Raw provenance mismatch ${id}`);
    const promptText = fs.readFileSync(path.join(dir, `prompt-master-${id}.txt`), 'utf8').replace(/\r?\n$/, '');
    if (r.prompt !== promptText) throw Error(`Prompt record mismatch ${id}`);
    attemptHistory.push({
      attempt: id, selected: id === attempt, tool: p.tool, tool_path: p.tool_path, mode: p.mode,
      raw: fileRecord(raw), original_generated_path: p.original_generated_path, byte_identical_to_original: true,
      request: fileRecord(path.join(dir, `request-master-${id}.json`)), prompt: fileRecord(path.join(dir, `prompt-master-${id}.txt`)),
      provenance: fileRecord(path.join(dir, `provenance-master-${id}.json`)),
      input_references: r.referenced_image_paths.map(fileRecord), status: p.status,
    });
  }
  json(path.join(dir, 'attempt-history.json'), { selected_attempt: attempt, built_in_only: true, attempts: attemptHistory });
  const record = await registerMaster('black-knight', input, completeProvenance);
  fs.copyFileSync(path.join(dir, 'source-vs-master.png'), path.join(dir, `comparison-master-${attempt}.png`));
  const rawMeta = await sharp(input).metadata();
  const rawBounds = await alphaBounds(input);
  const { data, info } = await sharp(input).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let zero = 0, partial = 0, opaque = 0;
  for (let i = 3; i < data.length; i += 4) { if (data[i] === 0) zero++; else if (data[i] === 255) opaque++; else partial++; }
  const registered = path.join(dir, record.source), mirrored = path.join(dir, record.mirror);
  const regBounds = await alphaBounds(registered, 64);
  const mirrorBounds = await alphaBounds(mirrored, 64);
  const pngs = [registered, mirrored].map(p => fs.readFileSync(p));
  const panes = [];
  const colors = ['#18232c', '#e6e0d4', '#889397'];
  for (let row = 0; row < colors.length; row++) {
    for (let col = 0; col < pngs.length; col++) {
      const bb = col ? mirrorBounds : regBounds;
      const cutout = await sharp(pngs[col]).extract({ left: bb.left - 12, top: bb.top - 12, width: bb.width + 24, height: bb.height + 24 }).png().toBuffer();
      const panel = await sharp({ create: { width: 390, height: 310, channels: 4, background: colors[row] } }).composite([{ input: cutout, left: Math.floor((390 - bb.width - 24) / 2), top: 40 }]).png().toBuffer();
      panes.push({ input: panel, left: col * 390, top: 55 + row * 310 });
    }
  }
  panes.push({ input: label('Shared-scale source / exact mirror; 1 image pixel = 1 review pixel', 780, 55, 18), left: 0, top: 0 });
  await sharp({ create: { width: 780, height: 985, channels: 4, background: '#18232c' } }).composite(panes).png().toFile(path.join(dir, `game-size-alpha-${attempt}.png`));
  fs.copyFileSync(path.join(dir, `game-size-alpha-${attempt}.png`), path.join(dir, 'game-size-alpha.png'));

  const large = await sharp(input).extract(cropRect(rawBounds)).resize({ height: 820 }).png().toBuffer();
  const lm = await sharp(large).metadata();
  const inspectionPanes = [];
  for (let i = 0; i < 2; i++) {
    const background = i ? '#e6e0d4' : '#18232c';
    const panel = await sharp({ create: { width: 760, height: 910, channels: 4, background } }).composite([{ input: large, left: Math.floor((760 - lm.width) / 2), top: 55 }]).png().toBuffer();
    inspectionPanes.push({ input: panel, left: i * 760, top: 0 });
  }
  inspectionPanes.push({ input: label('Raw master - dark matte', 760, 50, 22), left: 0, top: 0 });
  inspectionPanes.push({ input: label('Raw master - pale matte', 760, 50, 22), left: 760, top: 0 });
  await sharp({ create: { width: 1520, height: 910, channels: 4, background: '#18232c' } }).composite(inspectionPanes).png().toFile(path.join(dir, `alpha-inspection-${attempt}.png`));
  const checks = {
    kind: 'mechanical image measurements only; not engine or automated gameplay tests',
    attempt, raw: rawName, raw_sha256: sha(fs.readFileSync(input)), raw_dimensions: [info.width, info.height], has_alpha: rawMeta.hasAlpha,
    raw_bounds_alpha8: rawBounds, raw_alpha_counts: { zero, partial, opaque },
    raw_clear_margins_alpha8: { left: rawBounds.left, top: rawBounds.top, right: info.width - rawBounds.right, bottom: info.height - rawBounds.bottom },
    raw_no_edge_contact_alpha8: rawBounds.left > 0 && rawBounds.top > 0 && rawBounds.right < info.width && rawBounds.bottom < info.height,
    source_verification: sourceChecks,
    registered_bounds_alpha64: regBounds,
    registered_dimensions: record.cell,
    registered_box: record.registration,
    source_relative_scale: j.source_scale,
    original_reference: j.original_reference, anchor: j.anchor,
    scale_override: false, stretched: false,
    exact_mirror_verified: record.exact_mirror_verified,
    padding_at_least_40: regBounds.left >= 40 && regBounds.top >= 40 && regBounds.right <= 984 && regBounds.bottom <= 728,
    visual_approval: false, animation_generated: false, engine_imported: false, runtime_verified: false,
    outputs: ['master_rgba.png', record.source, record.mirror, 'source-vs-master.png', `comparison-master-${attempt}.png`, 'game-size-alpha.png', `game-size-alpha-${attempt}.png`, `alpha-inspection-${attempt}.png`].map(f => fileRecord(path.join(dir, f))),
  };
  json(path.join(dir, `mechanical-checks-${attempt}.json`), checks);
  json(path.join(dir, 'mechanical-checks.json'), checks);
  console.log(JSON.stringify({ attempt, raw: rawName, registered_bounds: regBounds, registration: record.registration, source_verification: sourceChecks, exact_mirror: record.exact_mirror_verified, output_count: checks.outputs.length }));
}
main().catch(e => { console.error(e); process.exitCode = 1; });
