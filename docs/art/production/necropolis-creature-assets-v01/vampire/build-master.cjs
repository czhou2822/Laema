'use strict';
// Mechanical preservation, evidence hashes and registration only. No artwork drawing.
const {
  root, sharp, fs, path, job, json, sha, alphaBounds, registerMaster,
} = require('../tools/lib.cjs');
const dir = __dirname;
const j = job('vampire');
const relative = p => path.relative(dir, p).replaceAll('\\', '/');
const hashFile = p => sha(fs.readFileSync(p));
const originalOutputs = [
  'C:/Users/zhouc/.codex/generated_images/01a16388-f539-7fb3-ade4-410eb691024d/exec-d50a83e9-4a2a-4b9b-b96a-784596af6251.png',
  'C:/Users/zhouc/.codex/generated_images/01a16388-f539-7fb3-ade4-410eb691024d/exec-7c205562-cb49-4650-89f6-ac12fa73fd5f.png',
];
async function main() {
  const metadataPath = path.resolve(root, j.source_metadata);
  const originalPath = path.resolve(root, j.original_def);
  const metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
  if (hashFile(metadataPath) !== j.source_metadata_sha256 ||
      hashFile(originalPath) !== j.original_def_sha256 ||
      JSON.stringify(metadata.groups) !== JSON.stringify(j.groups.map(g => g.native))) {
    throw Error('Native source identity differs from job.json');
  }
  const inspected = [
    'native-idle-6x.png', 'native-all-groups-contact.png', 'native-scale-guide.png',
    ...j.native_group_guides.map(p => path.basename(p)),
    '../references/pikeman-rendering-master.png',
  ];
  json(path.join(dir, 'source-evidence.json'), {
    source_id: j.source_id,
    inventory_authority: 'job.json (complete inventory retained there; not duplicated)',
    metadata: relative(metadataPath), metadata_sha256: hashFile(metadataPath),
    original_def: relative(originalPath), original_def_sha256: hashFile(originalPath),
    complete_native_groups_equal_job: true,
    totals: { groups: metadata.groups.length, timeline_frames: j.original_timeline_frames,
      distinct_indexed_drawings: j.original_distinct_indexed_drawings },
    sampling: 'Every group guide visually inspected at its labelled first, middle and last frame; contact sheet and enlarged idle also inspected. Static samples, not motion playback.',
    sampled_groups: j.groups.map(g => ({ id: g.id,
      frame_indices: [0, Math.floor(g.frame_count / 2), g.frame_count - 1] })),
    inspected_images: inspected.map(p => ({ file: p,
      sha256: hashFile(path.resolve(dir, p)) })),
    role_names: 'Format mappings in job.json; no runtime semantic or timing validation.',
  });
  fs.mkdirSync(path.join(dir, 'raw'), { recursive: true });
  const attempts = [];
  for (let index = 0; index < originalOutputs.length; index++) {
    const n = String(index + 1).padStart(2, '0');
    const rawPath = path.join(dir, 'raw', `master-attempt-${n}.png`);
    if (fs.existsSync(rawPath)) {
      if (hashFile(rawPath) !== hashFile(originalOutputs[index])) throw Error('Preserved raw differs');
    } else fs.copyFileSync(originalOutputs[index], rawPath);
    const requestFile = `generation-${n}.request.json`;
    const request = JSON.parse(fs.readFileSync(path.join(dir, requestFile), 'utf8'));
    const rawMetadata = await sharp(rawPath).metadata();
    attempts.push({
      attempt: index + 1, operation: index ? 'targeted claw-tip repair' : 'initial static master',
      tool_path: 'functions.exec -> tools.image_gen__imagegen (built-in image_gen.imagegen)',
      backend_model: 'not exposed by tool; not inferred',
      request_file: requestFile, request_file_sha256: hashFile(path.join(dir, requestFile)),
      exact_prompt: request.prompt, prompt_utf8_sha256: sha(Buffer.from(request.prompt, 'utf8')),
      transparent_background_requested: request.transparent_background,
      references: request.referenced_image_paths.map(p => ({ file: relative(p), sha256: hashFile(p) })),
      tool_saved_output: originalOutputs[index], preserved_raw: relative(rawPath),
      raw_sha256: hashFile(rawPath), raw_dimensions: [rawMetadata.width, rawMetadata.height],
      has_alpha: rawMetadata.hasAlpha, raw_alpha_bounds: await alphaBounds(rawPath),
      selected: index === 1,
    });
  }
  const provenance = {
    scope: 'Vampire base static master in complete Necropolis collection; awaiting human approval',
    source_evidence: 'source-evidence.json', chosen_raw: attempts[1].preserved_raw,
    attempts, mechanical_edits: 'Original raw bytes retained; alpha crop, uniform aspect-preserving scale, cell placement, exact horizontal mirror. No paint, color rewrite, matting or silhouette deformation.',
    registration_overrides: {},
  };
  json(path.join(dir, 'provenance.json'), provenance);
  const record = await registerMaster('vampire', path.join(dir, provenance.chosen_raw), {
    provenance_file: 'provenance.json', provenance_sha256: hashFile(path.join(dir, 'provenance.json')),
    chosen_raw: provenance.chosen_raw, raw_sha256: attempts[1].raw_sha256,
    tool_path: attempts[1].tool_path, request_files: attempts.map(a => a.request_file),
    source_evidence: 'source-evidence.json',
  });
  // Backgrounds are inspection previews only, never part of the transparent master.
  const previewLayers = [];
  for (const [i, background] of [[0, '#172936'], [1, '#e8e6df']]) {
    const pane = await sharp({ create: { width: 1024, height: 768, channels: 4, background } })
      .composite([{ input: path.join(dir, 'master_source_1024x768.png'), left: 0, top: 0 }])
      .png().toBuffer();
    previewLayers.push({ input: pane, left: i * 1024, top: 0 });
  }
  await sharp({ create: { width: 2048, height: 768, channels: 4, background: '#00000000' } })
    .composite(previewLayers).png().toFile(path.join(dir, 'alpha-review.png'));
  console.log(JSON.stringify({ selected_raw: provenance.chosen_raw,
    registered_bounds: record.actual_registered_bounds, registration: record.registration,
    transparent_background: record.transparent_background,
    exact_mirror_verified: record.exact_mirror_verified,
    source_hashes_match: true, output: relative(path.join(dir, 'master-manifest.json')) }, null, 2));
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
