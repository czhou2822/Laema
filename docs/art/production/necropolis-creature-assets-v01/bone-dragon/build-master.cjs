const { fs, path, root, sharp, sha, json, alphaBounds, cropRect, label, registerMaster } = require('../tools/lib.cjs');

(async () => {
  const dir = path.join(root, 'bone-dragon');
  const selectedAttempt = process.argv[2] || '04';
  if (!/^\d{2}$/.test(selectedAttempt)) throw Error('Attempt must be NN');
  const input = path.join(dir, `raw-${selectedAttempt}.png`);
  const call = JSON.parse(fs.readFileSync(path.join(dir, `tool-call-${selectedAttempt}.json`), 'utf8'));
  const record = await registerMaster('bone-dragon', input, {
    selected_raw: `raw-${selectedAttempt}.png`, exact_tool_call: `tool-call-${selectedAttempt}.json`,
    exact_prompt: `prompt-${selectedAttempt}.txt`, prompt_argument_utf8_sha256: call.prompt_argument_utf8_sha256,
    tool: call.tool, returned_generated_path: call.returned_generated_path,
    raw_sha256: call.archived_raw_sha256, source_evidence: 'source-evidence.json',
    art_direction: 'Source-led CNDRGN redraw; Pikeman supplies modeled-volume rendering only.',
    status: 'Static proposal awaiting user approval; animation has not begun.'
  });
  const panes = [];
  for (const [i, file, title] of [
    [0, 'native-scale-guide.png', 'CNDRGN native at shared scale'],
    [1, 'master_source_1024x768.png', 'Static proposal at shared scale'],
    [2, 'master_mirror_1024x768.png', 'Exact horizontal mirror']
  ]) {
    const png = fs.readFileSync(path.join(dir, file));
    const b = await alphaBounds(png, 64);
    panes.push({ input: await sharp(png).extract(cropRect(b)).png().toBuffer(), left: i * 400 + 200 + b.left - 512, top: 440 + b.top - 512 });
    panes.push({ input: label(title, 400, 560, 16), left: i * 400, top: 0 });
  }
  await sharp({ create: { width: 1200, height: 560, channels: 4, background: '#1b2936' } }).composite(panes).png().toFile(path.join(dir, 'game-size-review.png'));
  const master = fs.readFileSync(path.join(dir, 'master_rgba.png'));
  const fitted = await sharp(master).resize(360, 660, { fit: 'inside' }).png().toBuffer();
  const m = await sharp(fitted).metadata();
  const checker = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="400" height="740"><defs><pattern id="c" width="32" height="32" patternUnits="userSpaceOnUse"><rect width="32" height="32" fill="#a7a7a7"/><path d="M0 0h16v16H0zM16 16h16v16H16z" fill="#dfdfdf"/></pattern></defs><rect width="400" height="740" fill="url(#c)"/></svg>`);
  const panels = [];
  for (const [i, title, background] of [[0, 'Dark composite', '#1b2936'], [1, 'Light composite', '#e7e1d5'], [2, 'Checker composite', null], [3, 'Actual alpha channel', '#000000']]) {
    const base = background ? sharp({ create: { width: 400, height: 740, channels: 4, background } }) : sharp(checker);
    const artwork = i === 3 ? await sharp(fitted).extractChannel(3).png().toBuffer() : fitted;
    const caption = i === 1 || i === 2 ? Buffer.from(label(title, 400, 740, 18).toString().replace('#e9e7e0', '#1b2936')) : label(title, 400, 740, 18);
    panels.push({ input: await base.composite([{ input: artwork, left: Math.floor((400 - m.width) / 2), top: 60 + Math.floor((660 - m.height) / 2) }, { input: caption, left: 0, top: 0 }]).png().toBuffer(), left: i * 400, top: 0 });
  }
  await sharp({ create: { width: 1600, height: 740, channels: 4, background: '#1b2936' } }).composite(panels).png().toFile(path.join(dir, 'alpha-review.png'));
  const source = fs.readFileSync(path.join(dir, 'master_source_1024x768.png'));
  const { data, info } = await sharp(source).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let transparent = 0, opaque = 0, partial = 0, borderNonzero = 0;
  for (let y = 0; y < info.height; y++) for (let x = 0; x < info.width; x++) {
    const a = data[(y * info.width + x) * 4 + 3];
    if (!a) transparent++; else if (a === 255) opaque++; else partial++;
    if (a && (x === 0 || y === 0 || x === info.width - 1 || y === info.height - 1)) borderNonzero++;
  }
  const e = JSON.parse(fs.readFileSync(path.join(dir, 'source-evidence.json'), 'utf8'));
  const preservation = e.reference_hashes_before_work.map(({ file, sha256 }) => ({ file, unchanged: sha(fs.readFileSync(path.resolve(dir, file))) === sha256 }));
  if (preservation.some(x => !x.unchanged)) throw Error('A source reference changed');
  const originalSourcePreservation = {
    original_def_unchanged: sha(fs.readFileSync(path.resolve(root, e.original_def_path))) === e.original_def_sha256,
    metadata_unchanged: sha(fs.readFileSync(path.resolve(root, e.metadata_path))) === e.metadata_sha256
  };
  if (Object.values(originalSourcePreservation).some(x => !x)) throw Error('Original source bytes changed');
  const metrics = {
    selected_attempt: selectedAttempt, selected_raw: path.basename(input),
    cell: record.cell, anchor: record.anchor, original_reference: record.original_reference, source_scale: record.source_scale,
    target_bounds: record.target_native_bounds, registered_bounds_alpha64: record.actual_registered_bounds,
    registered_bounds_alpha8: await alphaBounds(source, 8), registration: record.registration,
    raw_to_cell_uniform_scale: { x: record.registration.width / record.registration.crop.width, y: record.registration.height / record.registration.crop.height, rounding_only: true },
    source_aspect: 93 / 114, generated_crop_aspect: record.registration.crop.width / record.registration.crop.height,
    width_difference_from_target_px: record.actual_registered_bounds.width - record.target_native_bounds.width,
    alpha: { transparent, opaque, partial, borderNonzero, corners_transparent: [0, (info.width - 1) * 4, (info.height - 1) * info.width * 4, (info.width * info.height - 1) * 4].every(n => data[n + 3] === 0) },
    exact_mirror_verified: record.exact_mirror_verified, reference_preservation: preservation,
    original_source_preservation: originalSourcePreservation,
    parent_registration_helper: { file: '../tools/lib.cjs', usage: 'read-only import', sha256: sha(fs.readFileSync(path.join(root, 'tools/lib.cjs'))) },
    outputs: ['master_rgba.png', 'master_source_1024x768.png', 'master_mirror_1024x768.png', 'source-vs-master.png', 'game-size-review.png', 'alpha-review.png'].map(file => ({ file, sha256: sha(fs.readFileSync(path.join(dir, file))) })),
    status: 'Mechanical image measurements only; does not establish human approval or runtime validation.'
  };
  json(path.join(dir, 'master-image-metrics.json'), metrics);
  console.log(JSON.stringify({ selected_raw: metrics.selected_raw, target_bounds: metrics.target_bounds, actual_bounds: metrics.registered_bounds_alpha64, alpha: metrics.alpha, reference_preservation: preservation.every(x => x.unchanged), exact_mirror_verified: metrics.exact_mirror_verified }, null, 2));
})().catch(error => { console.error(error); process.exitCode = 1; });
