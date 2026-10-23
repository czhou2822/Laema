// Mechanical registration and review exports only; no game build or import.
const { fs, path, sharp, sha, job, json, alphaBounds, cropRect, registerMaster } = require('../tools/lib.cjs');
const dir = __dirname;
const slug = 'vampire-lord';

async function main() {
  const [input, attempt = '01'] = process.argv.slice(2);
  if (!input || !/^\d{2}$/.test(attempt)) throw Error('Usage: node build-master.cjs <built-in PNG path> <two-digit attempt>');
  const j = job(slug);
  const packageRoot = path.resolve(dir, '..');
  const metadataPath = path.resolve(packageRoot, j.source_metadata);
  const defPath = path.resolve(packageRoot, j.original_def);
  const native = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
  const sourceChecks = {
    original_def: sha(fs.readFileSync(defPath)) === j.original_def_sha256,
    metadata: sha(fs.readFileSync(metadataPath)) === j.source_metadata_sha256,
    idle_png: sha(fs.readFileSync(path.join(dir, 'native-idle.png'))) === j.source_idle_frame_sha256,
    group_metadata: j.groups.every(g => JSON.stringify(g.native) === JSON.stringify(native.groups.find(n => n.id === g.id))),
    timeline_count: native.groups.reduce((n, g) => n + g.frames.length, 0) === j.original_timeline_frames,
    distinct_drawing_count: new Set(native.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size === j.original_distinct_indexed_drawings
  };
  if (Object.values(sourceChecks).some(v => !v)) throw Error('Original source / job verification failed: ' + JSON.stringify(sourceChecks));

  const rawName = `raw-generation-${attempt}.png`;
  const rawPath = path.join(dir, rawName);
  const bytes = fs.readFileSync(input);
  if (fs.existsSync(rawPath) && sha(fs.readFileSync(rawPath)) !== sha(bytes)) throw Error('Refusing to overwrite a different raw attempt');
  if (path.resolve(input) !== rawPath) fs.copyFileSync(input, rawPath);
  const requestName = `generation-${attempt}.request.json`;
  const requestPath = path.join(dir, requestName);
  const request = JSON.parse(fs.readFileSync(requestPath, 'utf8'));
  const provenance = {
    tool: 'built-in imagegen',
    tool_path: 'functions.exec -> tools.image_gen__imagegen',
    request_file: requestName,
    request_sha256: sha(fs.readFileSync(requestPath)),
    exact_prompt_sha256_utf8: sha(Buffer.from(request.prompt, 'utf8')),
    requested_transparent_background: request.transparent_background,
    reference_inputs: request.referenced_image_paths.map(p => ({ path: p, sha256: sha(fs.readFileSync(p)) })),
    selected_attempt: attempt,
    preserved_raw: rawName,
    raw_sha256: sha(bytes),
    builtin_output_path: path.resolve(input),
    raw_metadata: await sharp(rawPath).metadata(),
    shared_registration_helper: '../tools/lib.cjs',
    shared_registration_helper_sha256: sha(fs.readFileSync(path.join(packageRoot, 'tools', 'lib.cjs'))),
    original_source_checks: sourceChecks,
    source_group_count: j.original_flipbooks,
    source_timeline_frames: j.original_timeline_frames,
    source_distinct_indexed_drawings: j.original_distinct_indexed_drawings,
    source_roles: 'Format mappings in job.json; static guide review does not establish playback or timing.',
    artwork_scope: 'One static idle master for the full creature collection. Awaiting human approval; no animation production.'
  };
  json(path.join(dir, `generation-${attempt}.provenance.json`), provenance);
  json(path.join(dir, 'generation-provenance.json'), provenance);
  const record = await registerMaster(slug, rawPath, provenance);

  // At 1:1 saved game scale, show source and both generated facings on two mattes.
  const width = 900, height = 660, rowHeight = 330;
  const layers = [{ input: Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="900" height="330"><rect width="900" height="330" fill="#e2ded3"/></svg>'), left: 0, top: rowHeight }];
  const columns = [
    ['native-scale-guide.png', 'Original CNOSFE / shared scale'],
    ['master_source_1024x768.png', 'Master / original facing right'],
    ['master_mirror_1024x768.png', 'Master / mechanical mirror left']
  ];
  for (let row = 0; row < 2; row++) {
    for (let column = 0; column < columns.length; column++) {
      const [name, title] = columns[column];
      const p = path.join(dir, name);
      const b = await alphaBounds(p, 8);
      const crop = await sharp(p).extract(cropRect(b)).png().toBuffer();
      const ink = row ? '#1b2936' : '#ece7de';
      const heading = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="300" height="50"><text x="12" y="25" fill="${ink}" font-family="Arial" font-size="15">${title}</text><text x="12" y="45" fill="${ink}" font-family="Arial" font-size="12">1:1 pixels / ${row ? 'light matte' : 'dark matte'}</text></svg>`);
      layers.push({ input: heading, left: column * 300, top: row * rowHeight });
      layers.push({ input: crop, left: column * 300 + 150 + b.left - j.anchor[0], top: row * rowHeight + 70 + b.top - j.target_master_alpha_bounds.top });
    }
  }
  await sharp({ create: { width, height, channels: 4, background: '#1b2936' } }).composite(layers).png().toFile(path.join(dir, 'game-size-mattes.png'));
  console.log(JSON.stringify({ selected_attempt: attempt, source_checks: sourceChecks, raw: rawName, raw_sha256: sha(bytes), registration: record.registration, actual_registered_bounds: record.actual_registered_bounds, exact_mirror_verified: record.exact_mirror_verified, status: record.status }, null, 2));
}

main().catch(e => { console.error(e.message); process.exitCode = 1; });
