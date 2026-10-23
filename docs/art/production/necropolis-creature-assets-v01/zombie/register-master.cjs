const { fs, path, sharp, json, sha, alphaBounds, job, registerMaster } = require('../tools/lib.cjs');

// Mechanical copy, metadata/provenance capture, uniform registration and review exports only.
// All character artwork is supplied by the built-in image generation tool.
const dir = __dirname;
const attempts = [
  {
    number: 1,
    tool_output_path: 'C:/Users/zhouc/.codex/generated_images/01a16383-567f-7311-8fea-87f05485d7f9/exec-009cef1e-bd47-4d60-9668-bcd0e99970e6.png',
    local_raw: 'attempt-01-raw.png',
    prompt_file: 'attempt-01-prompt.txt',
    tool: 'image_gen.imagegen',
    transparent_background_requested: true,
    references: ['native-idle-6x.png', 'native-g12-guide.png', '../references/pikeman-rendering-master.png'],
    selected: true
  }
];

(async () => {
  for (const a of attempts) {
    const local = path.join(dir, a.local_raw);
    if (!fs.existsSync(local)) fs.copyFileSync(a.tool_output_path, local);
    a.tool_output_sha256 = sha(fs.readFileSync(a.tool_output_path));
    a.local_raw_sha256 = sha(fs.readFileSync(local));
    if (a.tool_output_sha256 !== a.local_raw_sha256) throw Error('Raw copy does not match tool output');
    const promptBytes = fs.readFileSync(path.join(dir, a.prompt_file));
    a.prompt_file_sha256 = sha(promptBytes);
    // The text file has its conventional final LF; the actual tool argument did not.
    a.exact_prompt = promptBytes.toString('utf8').replace(/\r?\n$/, '');
    a.prompt_sha256 = sha(Buffer.from(a.exact_prompt));
    a.image_metadata = await sharp(local).metadata();
    a.alpha_bounds_8 = await alphaBounds(local, 8);
    a.alpha_bounds_64 = await alphaBounds(local, 64);
    a.reference_hashes = a.references.map(reference => ({ reference, sha256: sha(fs.readFileSync(path.resolve(dir, reference))) }));
  }
  const selected = attempts.find(a => a.selected);
  if (!selected || attempts.filter(a => a.selected).length !== 1) throw Error('Exactly one master must be selected');
  const provenance = {
    subject: 'Zombie',
    source_id: 'CZOMLO',
    approval_status: 'static master awaiting human approval',
    method: 'built-in image_gen; no API or CLI fallback',
    selected_attempt: selected.number,
    selected_raw: selected.local_raw,
    generated_sha256: selected.local_raw_sha256,
    attempts
  };
  json(path.join(dir, 'generation-provenance.json'), provenance);
  const manifest = await registerMaster('zombie', path.join(dir, selected.local_raw), provenance);
  // Opaque review images expose the real alpha edge over two contrasting mattes.
  const master = path.join(dir, 'master_rgba.png');
  const mm = await sharp(master).metadata();
  const dark = await sharp(master).flatten({ background: '#1b2936' }).png().toBuffer();
  const light = await sharp(master).flatten({ background: '#e8e6df' }).png().toBuffer();
  await sharp({ create: { width: mm.width * 2, height: mm.height, channels: 4, background: '#1b2936' } })
    .composite([{ input: dark, left: 0, top: 0 }, { input: light, left: mm.width, top: 0 }])
    .png().toFile(path.join(dir, 'alpha-edge-review.png'));
  const j = job('zombie');
  const metadataPath = path.resolve(dir, '..', j.source_metadata);
  const defPath = path.resolve(dir, '..', j.original_def);
  const nativeMetadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
  const sourceEvidence = {
    original_metadata_path: metadataPath,
    metadata_sha256: sha(fs.readFileSync(metadataPath)),
    metadata_matches_job: sha(fs.readFileSync(metadataPath)) === j.source_metadata_sha256,
    original_def_path: defPath,
    original_def_sha256: sha(fs.readFileSync(defPath)),
    original_def_matches_job: sha(fs.readFileSync(defPath)) === j.original_def_sha256,
    idle_sha256: sha(fs.readFileSync(path.join(dir, 'native-idle.png'))),
    idle_matches_job: sha(fs.readFileSync(path.join(dir, 'native-idle.png'))) === j.source_idle_frame_sha256,
    groups: nativeMetadata.groups.map(g => ({ id: g.id, block: g.block, frame_count: g.frames.length, cell: [g.cell_width, g.cell_height], frame_names: g.frames.map(f => f.name), format_role_from_job: j.groups.find(n => n.id === g.id).role_format_mapping, role_runtime_verified: false })),
    timeline_frames: nativeMetadata.groups.reduce((n, g) => n + g.frames.length, 0),
    distinct_indexed_drawings: new Set(nativeMetadata.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size,
    native_idle_alpha64: await alphaBounds(path.join(dir, 'native-idle.png'), 64),
    registered_alpha64: manifest.actual_registered_bounds,
    exact_mirror_verified_by_helper: manifest.exact_mirror_verified,
    generated_art_is_native_pixel_enlargement: false,
    tests_or_runtime_performed: false
  };
  json(path.join(dir, 'source-evidence.json'), sourceEvidence);
  console.log(JSON.stringify({ selected_raw: selected.local_raw, generated_sha256: selected.local_raw_sha256, source_evidence: { metadata_matches_job: sourceEvidence.metadata_matches_job, original_def_matches_job: sourceEvidence.original_def_matches_job, idle_matches_job: sourceEvidence.idle_matches_job, groups: sourceEvidence.groups.length, frames: sourceEvidence.timeline_frames, distinct_drawings: sourceEvidence.distinct_indexed_drawings }, registration: manifest.registration, registered_bounds: manifest.actual_registered_bounds, source_sha256: manifest.source_sha256, mirror_sha256: manifest.mirror_sha256 }, null, 2));
})().catch(error => { console.error(error); process.exitCode = 1; });
