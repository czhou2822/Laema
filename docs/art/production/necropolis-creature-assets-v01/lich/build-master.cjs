'use strict';
// Artifact-only mechanical registration. All writes remain in this Lich folder.
const { fs, path, sharp, root, sha, job, json, alphaBounds, cropRect, label, registerMaster } = require('../tools/lib.cjs');
const dir = __dirname;
const local = name => path.join(dir, name);
const digest = file => sha(fs.readFileSync(file));

async function main() {
  const j = job('lich');
  const receipt = JSON.parse(fs.readFileSync(local('generation-result-01.json'), 'utf8'));
  const request = JSON.parse(fs.readFileSync(local('requests/master-01.json'), 'utf8'));
  const prompt = fs.readFileSync(local('prompts/master-01.txt'), 'utf8');
  if (prompt !== request.arguments.prompt) throw Error('Exact prompt file and recorded request differ.');
  const rawPath = local(receipt.preserved_raw);
  fs.mkdirSync(path.dirname(rawPath), { recursive: true });
  const sourceRaw = fs.readFileSync(receipt.returned_file);
  if (fs.existsSync(rawPath)) {
    if (digest(rawPath) !== sha(sourceRaw)) throw Error('Existing raw differs; preserve it.');
  } else fs.copyFileSync(receipt.returned_file, rawPath);

  const metadataPath = path.resolve(root, j.source_metadata);
  const originalPath = path.resolve(root, j.original_def);
  const metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
  if (digest(metadataPath) !== j.source_metadata_sha256) throw Error('Native metadata hash mismatch.');
  if (digest(originalPath) !== j.original_def_sha256) throw Error('Original DEF hash mismatch.');
  if (JSON.stringify(metadata.groups) !== JSON.stringify(j.groups.map(g => g.native))) throw Error('Native group metadata differs from job.');

  const inspected = [
    'native-idle-6x.png', 'native-all-groups-contact.png',
    'native-g02-guide.png', 'native-g04-guide.png', 'native-g07-guide.png',
    'native-g12-guide.png', 'native-g15-guide.png'
  ];
  const provenance = {
    tool: 'image_gen.imagegen',
    workflow: 'built-in image generation with three local image references; one master call',
    request: 'requests/master-01.json',
    request_sha256: digest(local('requests/master-01.json')),
    exact_prompt: 'prompts/master-01.txt',
    prompt_sha256: digest(local('prompts/master-01.txt')),
    tool_result_record: 'generation-result-01.json',
    tool_returned_file: receipt.returned_file,
    chosen_raw: receipt.preserved_raw,
    raw_sha256: digest(rawPath),
    raw_byte_identical_to_tool_output: digest(rawPath) === sha(sourceRaw),
    raw_alpha_bounds: await alphaBounds(rawPath),
    generation_references: request.arguments.referenced_image_paths.map((p, index) => ({
      index: index + 1,
      role: index === 2 ? 'rendering finish only' : 'original CLICH identity and idle pose',
      path: path.relative(dir, p).split(path.sep).join('/'),
      sha256: digest(p)
    })),
    inspected_native_guides: inspected.map(name => ({ path: name, sha256: digest(local(name)) })),
    native_metadata: {
      path: path.relative(dir, metadataPath).split(path.sep).join('/'),
      sha256: digest(metadataPath),
      original_def_sha256: digest(originalPath),
      all_job_native_groups_equal: true,
      group_count: metadata.groups.length,
      timeline_frames: metadata.frame_count,
      distinct_indexed_drawings: new Set(metadata.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size
    },
    job_sha256: digest(local('job.json')),
    registration_helper: '../tools/lib.cjs',
    registration_helper_sha256: digest(path.join(root, 'tools/lib.cjs')),
    reference_scope: 'Entire CLICH collection is retained in job.json; static idle master approval only.',
    processing: 'Byte-preserving raw copy; alpha crop; uniform aspect-preserving scale; translation; exact horizontal mirror. No painted or generated changes through code.',
    interpretation_limit: 'Fine source pixels resolve costume and materials; high-resolution chain-link, clasp and facial detail are generated interpretations.'
  };
  json(local('provenance.json'), provenance);
  const record = await registerMaster('lich', rawPath, provenance);
  const sourceCell = local('master_source_1024x768.png');
  const mirrorCell = local('master_mirror_1024x768.png');
  const native = local('native-scale-guide.png');
  const pieces = [];
  const columns = [
    [native, 'Original at shared scale', '#1b2936'],
    [sourceCell, 'Master at shared scale', '#1b2936'],
    [mirrorCell, 'Exact mirror', '#1b2936'],
    [sourceCell, 'Master on light ground', '#e4e0d5']
  ];
  for (let i = 0; i < columns.length; i++) {
    const [file, title, bg] = columns[i];
    const b = await alphaBounds(file, 64);
    const sprite = await sharp(file).extract(cropRect(b)).png().toBuffer();
    pieces.push({ input: await sharp({ create: { width: 250, height: 410, channels: 4, background: bg } }).png().toBuffer(), left: i * 250, top: 0 });
    pieces.push({ input: sprite, left: i * 250 + Math.round((250 - b.width) / 2), top: 350 - b.height });
    if (i === 3) {
      const titleSvg = label(title, 250, 50, 15).toString().replace('#e9e7e0', '#1b2936');
      pieces.push({ input: Buffer.from(titleSvg), left: i * 250, top: 0 });
    } else pieces.push({ input: label(title, 250, 50, 15), left: i * 250, top: 0 });
  }
  const nativeIdle = local('native-idle.png');
  const nb = await alphaBounds(nativeIdle, 64);
  const nativeCrop = await sharp(nativeIdle).extract(cropRect(nb)).png().toBuffer();
  const mb = await alphaBounds(sourceCell, 64);
  const small = await sharp(sourceCell).extract(cropRect(mb)).resize({ height: nb.height, kernel: 'lanczos3' }).png().toBuffer();
  const sm = await sharp(small).metadata();
  pieces.push({ input: label('Native-density comparison (91px): original / generated', 650, 50, 17), left: 0, top: 415 });
  pieces.push({ input: nativeCrop, left: 200, top: 565 - nb.height });
  pieces.push({ input: small, left: 310, top: 565 - sm.height });
  pieces.push({ input: label('Static proposal; animation and runtime unverified', 700, 50, 17), left: 0, top: 575 });
  await sharp({ create: { width: 1000, height: 630, channels: 4, background: '#1b2936' } }).composite(pieces).png().toFile(local('game-size-review.png'));
  const outputs = ['master_rgba.png','master_source_1024x768.png','master_mirror_1024x768.png','source-vs-master.png','game-size-review.png'];
  const checks = {
    scope: 'Static image measurements only; no engine, game, test runner or Git command.',
    raw_copied_exactly: digest(rawPath) === sha(sourceRaw),
    raw_dimensions: await sharp(rawPath).metadata().then(m => [m.width, m.height]),
    registered_cell: j.cell,
    anchor: j.anchor,
    original_reference: j.original_reference,
    shared_scale: j.source_scale,
    target_bounds: j.target_master_alpha_bounds,
    actual_bounds: record.actual_registered_bounds,
    options: record.registration.options,
    exact_mirror_verified: record.exact_mirror_verified,
    native_idle_sha256: digest(nativeIdle),
    native_idle_matches_job: digest(nativeIdle) === j.source_idle_frame_sha256,
    outputs: outputs.map(file => ({ file, sha256: digest(local(file)) })),
    transparency: await alphaBounds(sourceCell),
    animation_generated: false,
    engine_imported: false,
    runtime_verified: false,
    human_approved: false
  };
  json(local('artifact-checks.json'), checks);
  console.log(JSON.stringify({ chosen_raw: receipt.preserved_raw, registration: record.registration, actual_bounds: record.actual_registered_bounds, raw_copied_exactly: checks.raw_copied_exactly, native_idle_matches_job: checks.native_idle_matches_job, exact_mirror_verified: record.exact_mirror_verified }, null, 2));
}
main().catch(error => { console.error(error); process.exitCode = 1; });
