'use strict';
// Artifact-only mechanical registration; shared helper and source evidence stay read-only.
const assert = require('node:assert/strict');
const {
  root, sharp, fs, path, job, json, sha, alphaBounds, cropRect, registerMaster
} = require('../tools/lib.cjs');
const dir = __dirname;
const slug = 'power-lich';
assert.equal(path.resolve(dir), path.join(root, slug));
const local = name => {
  const resolved = path.resolve(dir, name);
  assert.ok(resolved.startsWith(dir + path.sep), 'Output must stay inside Power Lich folder');
  return resolved;
};
const hashFile = p => sha(fs.readFileSync(p));
async function main() {
  const j = job(slug);
  const metadataPath = path.resolve(root, j.source_metadata);
  const defPath = path.resolve(root, j.original_def);
  const original = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
  assert.equal(hashFile(metadataPath), j.source_metadata_sha256, 'Original metadata changed');
  assert.equal(hashFile(defPath), j.original_def_sha256, 'Original DEF changed');
  assert.equal(hashFile(local('native-idle.png')), j.source_idle_frame_sha256);
  assert.deepEqual(original.groups, j.groups.map(g => g.native));
  assert.equal(original.frame_count, j.original_timeline_frames);
  const origin = JSON.parse(fs.readFileSync(local('generation-attempt-05.json'), 'utf8'));
  const generatedToolPath = local(origin.raw_file);
  assert.equal(hashFile(generatedToolPath), hashFile(origin.tool_output_file), 'Raw copy differs from tool output');
  const eyeRepair = await require('./repair-eye.cjs')();
  const rawPath = local(eyeRepair.output_file);
  const sampled = [
    { group: 0, frames: [0, 4, 7] },
    { group: 2, frames: [0, 4, 7] },
    { group: 4, frames: [0, 5, 10] },
    { group: 7, frames: [0, 1] },
    { group: 12, frames: [0, 4, 7] },
    { group: 15, frames: [0, 5, 10] }
  ];
  const referenceNames = [
    'native-idle.png', 'native-idle-6x.png', 'native-scale-guide.png',
    'native-all-groups-contact.png', 'native-g00-guide.png', 'native-g02-guide.png',
    'native-g04-guide.png', 'native-g07-guide.png', 'native-g12-guide.png',
    'native-g15-guide.png'
  ];
  const provenance = {
    tool: origin.tool,
    tool_mode: origin.tool_mode,
    exact_arguments: 'prompts/attempt-05.json',
    exact_arguments_sha256: hashFile(local('prompts/attempt-05.json')),
    raw_file: origin.raw_file,
    raw_sha256: hashFile(generatedToolPath),
    registered_input_file: eyeRepair.output_file,
    registered_input_sha256: eyeRepair.output_sha256,
    eye_repair: eyeRepair,
    source_head_audit: {
      file: '../references/native-power-lich-head-audit.png',
      sha256: hashFile(path.join(root, 'references/native-power-lich-head-audit.png')),
      observation: 'Two small red facial/socket accents below the crown; not crown stones'
    },
    original_tool_output: origin.tool_output_file,
    original_tool_output_sha256: hashFile(origin.tool_output_file),
    tool_output_record: 'generation-attempt-05.json',
    selected_attempt: 5,
    history: [1, 2, 3, 4, 5].map(n => ({
      attempt: n, prompt_file: 'prompts/attempt-0' + n + '.json',
      prompt_sha256: hashFile(local('prompts/attempt-0' + n + '.json')),
      raw_file: 'raw/attempt-0' + n + '.png',
      raw_sha256: hashFile(local('raw/attempt-0' + n + '.png')),
      tool_record: 'generation-attempt-0' + n + '.json'
    })),
    earlier_attempt: {
      raw_file: 'raw/attempt-01.png',
      raw_sha256: hashFile(local('raw/attempt-01.png')),
      prompt_file: 'prompts/attempt-01.json',
      prompt_sha256: hashFile(local('prompts/attempt-01.json')),
      tool_record: 'generation-attempt-01.json',
      first_comparison: 'raw/attempt-01-source-vs-master.png',
      outcome: 'Superseded for high waist and short hanging arm. Earlier rejection of all red eye detail was incorrect; source accents restored by selected eye-only repair.'
    },
    source_id: j.source_id,
    source_idle: { group: 2, frame: 0, name: j.source_idle_frame.name, pixel_hash: j.source_idle_frame.index_sha256 },
    native_source_metadata: j.source_metadata,
    native_source_metadata_resolution_base: '.. (collection root)',
    native_original_def: j.original_def,
    native_groups_equal_job: true,
    reference_images: referenceNames.map(name => ({ file: name, sha256: hashFile(local(name)) })),
    rendering_benchmark: {
      file: '../references/pikeman-rendering-master.png',
      sha256: hashFile(path.join(root, 'references/pikeman-rendering-master.png')),
      role: 'Rendering only; not Necropolis anatomy, costume, palette or pose'
    },
    visually_sampled_guides: sampled,
    contact_sheet: 'native-all-groups-contact.png; one representative per original group, not complete motion review',
    registration_helper: {
      file: '../tools/lib.cjs',
      sha256: hashFile(path.join(root, 'tools/lib.cjs')),
      read_only: true
    },
    registration_script: 'build-master.cjs',
    registration_script_sha256: hashFile(__filename),
    scope: 'static master proposal only; awaiting human approval',
    further_generation: false
  };
  const record = await registerMaster(slug, rawPath, provenance);
  const rawMeta = await sharp(rawPath).metadata();
  const rawBounds = await alphaBounds(rawPath, 8);
  const master = local('master_rgba.png');
  const masterMeta = await sharp(master).metadata();
  const previewHeight = 560;
  const previewWidth = Math.round(masterMeta.width * previewHeight / masterMeta.height);
  const preview = await sharp(master).resize(previewWidth, previewHeight).png().toBuffer();
  const panels = [];
  for (const background of ['#e8e5dd', '#1b2936']) {
    panels.push(await sharp({
      create: { width: 400, height: 620, channels: 4, background }
    }).composite([{
      input: preview, left: Math.round((400 - previewWidth) / 2), top: 30
    }]).png().toBuffer());
  }
  await sharp({ create: { width: 800, height: 620, channels: 4, background: '#e8e5dd' } })
    .composite(panels.map((input, index) => ({ input, left: index * 400, top: 0 })))
    .png().toFile(local('cutout-background-review.png'));
  json(local('artifact-audit.json'), {
    status: 'mechanical artifact verification; no tests, build, engine or runtime',
    source_hashes_match_job: true,
    original_metadata_groups_equal_job: true,
    original_group_count: original.groups.length,
    original_timeline_frames: original.frame_count,
    original_distinct_drawings: j.original_distinct_indexed_drawings,
    native_idle_frame_sha256: hashFile(local('native-idle.png')),
    raw: {
      file: eyeRepair.output_file, sha256: hashFile(rawPath),
      width: rawMeta.width, height: rawMeta.height,
      has_alpha: rawMeta.hasAlpha, bounds_alpha8: rawBounds
    },
    generated_tool_raw: { file: origin.raw_file, sha256: hashFile(generatedToolPath) },
    eye_repair: eyeRepair,
    registration: record.registration,
    registered_alpha64: record.actual_registered_bounds,
    exact_mirror_verified: record.exact_mirror_verified,
    helper_sha256: provenance.registration_helper.sha256,
    visually_sampled_guides: sampled,
    outputs: [
      'master_rgba.png', 'master_source_1024x768.png', 'master_mirror_1024x768.png',
      'source-vs-master.png', 'cutout-background-review.png', 'eye-repair-review.png',
      'eye-repair-provenance.json', 'master-manifest.json'
    ].map(name => ({ file: name, sha256: hashFile(local(name)) })),
    human_approved: false, animation_generated: false, engine_imported: false,
    runtime_verified: false
  });
  console.log(JSON.stringify({
    status: record.status,
    raw_sha256: hashFile(rawPath),
    master_sha256: record.high_res_sha256,
    registered: record.actual_registered_bounds,
    registration: record.registration,
    exact_mirror_verified: record.exact_mirror_verified
  }, null, 2));
}
main().catch(error => { console.error(error); process.exitCode = 1; });
