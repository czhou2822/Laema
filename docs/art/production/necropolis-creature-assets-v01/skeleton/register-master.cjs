const { root, sharp, fs, path, job, json, sha, alphaBounds, registerMaster } = require('../tools/lib.cjs');

async function main() {
  const slug = 'skeleton';
  const dir = path.join(root, slug);
  const j = job(slug);
  const toolOutput = 'C:/Users/zhouc/.codex/generated_images/01a16383-53e2-7d13-961e-482bcd4abce7/exec-4a2e4e3f-16a6-4033-ac1b-44f29fe9f6d7.png';
  const raw = path.join(dir, 'generated-01-raw.png');
  if (!fs.existsSync(raw)) fs.copyFileSync(toolOutput, raw, fs.constants.COPYFILE_EXCL);
  if (sha(fs.readFileSync(raw)) !== sha(fs.readFileSync(toolOutput))) throw Error('Raw copy differs from tool output');
  const references = [
    { path: path.join(dir, 'native-idle-6x.png'), role: 'identity, pose, silhouette, equipment, colors' },
    { path: path.join(dir, 'native-g02-guide.png'), role: 'native idle pose confirmation; first pose only' },
    { path: path.join(root, 'references/pikeman-rendering-master.png'), role: 'rendering style only' }
  ].map(r => ({ ...r, sha256: sha(fs.readFileSync(r.path)) }));
  const sourceMetadata = path.resolve(root, j.source_metadata);
  const originalDef = path.resolve(root, j.original_def);
  const metadataBytes = fs.readFileSync(sourceMetadata);
  const nativeMetadata = JSON.parse(metadataBytes);
  const sourceEvidence = {
    metadata_path: sourceMetadata,
    metadata_sha256: sha(metadataBytes),
    expected_metadata_sha256: j.source_metadata_sha256,
    original_def_path: originalDef,
    original_def_sha256: sha(fs.readFileSync(originalDef)),
    expected_original_def_sha256: j.original_def_sha256,
    idle_frame: nativeMetadata.groups.find(g => g.id === 2).frames[0],
    native_group_count: nativeMetadata.groups.length,
    native_timeline_frame_count: nativeMetadata.frame_count,
    distinct_indexed_drawings: j.original_distinct_indexed_drawings,
    native_groups: j.groups.map(g => ({ id: g.id, format_mapping: g.role_format_mapping, frame_count: g.frame_count, distinct_indexed_drawings: g.distinct_indexed_drawings, role_mapping_is_not_runtime_verified: true }))
  };
  if (sourceEvidence.metadata_sha256 !== j.source_metadata_sha256 || sourceEvidence.original_def_sha256 !== j.original_def_sha256) throw Error('Native source provenance mismatch');
  const prompt = fs.readFileSync(path.join(dir, 'generation-01.prompt.txt'), 'utf8').trimEnd();
  const provenance = {
    method: 'built-in image_gen only; no CLI or API fallback',
    status: 'static master proposal awaiting human approval',
    selected_attempt: 1,
    selected_raw: 'generated-01-raw.png',
    attempts: [{
      attempt: 1,
      operation: 'generation with native identity and rendering-style reference images',
      prompt_file: 'generation-01.prompt.txt',
      exact_prompt: prompt,
      prompt_sha256_utf8: sha(Buffer.from(prompt, 'utf8')),
      transparent_background: true,
      referenced_image_paths: references,
      tool_output_path: toolOutput,
      preserved_raw: 'generated-01-raw.png',
      generated_sha256: sha(fs.readFileSync(raw)),
      generated_metadata: await sharp(raw).metadata(),
      generated_alpha_bounds: await alphaBounds(raw),
      disposition: 'selected for static human review; not accepted production art'
    }],
    source_evidence: sourceEvidence,
    mechanical_operations: ['byte-exact raw copy', 'alpha-bound crop', 'aspect-preserving uniform registration', 'horizontal mirror', 'side-by-side static preview'],
    registration_override: null,
    animation_generated: false,
    engine_imported: false,
    runtime_verified: false,
    human_approved: false
  };
  json(path.join(dir, 'generation-provenance.json'), provenance);
  const manifest = await registerMaster(slug, raw, provenance);
  console.log(JSON.stringify({ selected_raw_sha256: provenance.attempts[0].generated_sha256, raw_bounds: provenance.attempts[0].generated_alpha_bounds, high_res_sha256: manifest.high_res_sha256, source_sha256: manifest.source_sha256, registered_bounds: manifest.actual_registered_bounds, registration: manifest.registration, exact_mirror_verified: manifest.exact_mirror_verified }, null, 2));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
