const { root, sharp, fs, path, job, json, sha, alphaBounds, registerMaster } = require('../tools/lib.cjs');

async function main() {
  const slug = 'skeleton-warrior';
  const dir = path.join(root, slug);
  const [toolOutputPath, attemptText] = process.argv.slice(2);
  const attempt = Number(attemptText);
  if (!toolOutputPath || !Number.isInteger(attempt) || attempt < 1 || attempt > 3) {
    throw new Error('Usage: node register-master.cjs TOOL_OUTPUT_PATH ATTEMPT_1_TO_3');
  }
  const number = String(attempt).padStart(2, '0');
  const rawRelative = `raw/generated-attempt-${number}.png`;
  const raw = path.join(dir, rawRelative);
  const submissionsPath = path.join(dir, 'tool-submissions.json');
  const submissions = fs.existsSync(submissionsPath) ? JSON.parse(fs.readFileSync(submissionsPath, 'utf8')).calls : [];
  const submitted = submissions.find(call => call.attempt === attempt);
  fs.mkdirSync(path.dirname(raw), { recursive: true });
  const toolBytes = fs.readFileSync(toolOutputPath);
  if (fs.existsSync(raw) && sha(fs.readFileSync(raw)) !== sha(toolBytes)) {
    throw new Error('Raw attempt already exists with different content; preserve it');
  }
  if (!fs.existsSync(raw)) fs.copyFileSync(toolOutputPath, raw);

  const referencePaths = attempt === 1 ? [
    'native-idle-6x.png',
    'native-g07-guide.png',
    'native-g01-guide.png',
    '../references/pikeman-rendering-master.png',
  ] : [
    `raw/generated-attempt-${String(attempt - 1).padStart(2, '0')}.png`,
    'native-idle-6x.png',
    'native-g07-guide.png',
    'native-g01-guide.png',
    '../references/pikeman-rendering-master.png',
  ];
  const provenance = {
    tool: 'image_gen.imagegen (built-in)',
    mode: attempt === 1 ? 'reference generation' : 'targeted identity correction',
    attempt,
    prompt_file: `prompt-attempt-${number}.txt`,
    exact_prompt: submitted?.arguments.prompt ?? fs.readFileSync(path.join(dir, `prompt-attempt-${number}.txt`), 'utf8'),
    exact_tool_arguments_file: 'tool-submissions.json',
    tool_output_hint: submitted?.output.output_hint ?? null,
    transparent_background_requested: true,
    referenced_image_paths: referencePaths.map(relative => ({
      relative_path: relative,
      sha256: sha(fs.readFileSync(path.resolve(dir, relative))),
    })),
    tool_output_path: toolOutputPath,
    tool_output_sha256: sha(toolBytes),
    preserved_raw: rawRelative,
    preserved_raw_sha256: sha(fs.readFileSync(raw)),
    raw_metadata: await sharp(raw).metadata(),
    raw_alpha_bounds: await alphaBounds(raw, 64),
    selected_for_master: true,
  };
  const ledgerPath = path.join(dir, 'generation-provenance.json');
  const ledger = fs.existsSync(ledgerPath) ? JSON.parse(fs.readFileSync(ledgerPath, 'utf8')) : {
    creature: 'Skeleton Warrior',
    status: 'static master awaiting human approval',
    built_in_only: true,
    animation_begun: false,
    attempts: [],
  };
  for (const prior of ledger.attempts) {
    prior.selected_for_master = false;
    const priorSubmitted = submissions.find(call => call.attempt === prior.attempt);
    if (priorSubmitted) {
      prior.exact_prompt = priorSubmitted.arguments.prompt;
      prior.exact_tool_arguments_file = 'tool-submissions.json';
      prior.tool_output_hint = priorSubmitted.output.output_hint;
    }
  }
  const existing = ledger.attempts.findIndex(value => value.attempt === attempt);
  if (existing < 0) ledger.attempts.push(provenance);
  else ledger.attempts[existing] = provenance;
  ledger.selected_raw = rawRelative;
  ledger.selected_raw_sha256 = provenance.preserved_raw_sha256;
  json(ledgerPath, ledger);

  const j = job(slug);
  const sourceMetadataPath = path.resolve(root, j.source_metadata);
  const sourceMetadataBytes = fs.readFileSync(sourceMetadataPath);
  const sourceMetadata = JSON.parse(sourceMetadataBytes);
  const sourceDefPath = path.resolve(root, j.original_def);
  json(path.join(dir, 'source-inspection.json'), {
    source_metadata_path: j.source_metadata,
    source_metadata_sha256: sha(sourceMetadataBytes),
    source_metadata_hash_matches_job: sha(sourceMetadataBytes) === j.source_metadata_sha256,
    source_original_path: j.original_def,
    source_original_sha256: sha(fs.readFileSync(sourceDefPath)),
    source_original_hash_matches_job: sha(fs.readFileSync(sourceDefPath)) === j.original_def_sha256,
    native_groups_exactly_match_job: JSON.stringify(sourceMetadata.groups) === JSON.stringify(j.groups.map(g => g.native)),
    source_header: Object.fromEntries(Object.entries(sourceMetadata).filter(([key]) => key !== 'groups')),
    original_group_count: j.groups.length,
    group_inventory_authority: 'job.json (full inventory retained there without duplication)',
    original_timeline_frames: sourceMetadata.groups.reduce((n, g) => n + g.frames.length, 0),
    original_distinct_indexed_drawings: new Set(sourceMetadata.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size,
    source_idle_frame: j.source_idle_frame,
    source_idle_bounds_alpha64: j.source_idle_bounds_alpha64,
    source_scale: j.source_scale,
    target_master_alpha_bounds: j.target_master_alpha_bounds,
    mechanical_inventory_only: true,
  });

  const record = await registerMaster(slug, raw, provenance);
  console.log(JSON.stringify({ selected_raw: rawRelative, generated_sha256: provenance.preserved_raw_sha256, registration: record.registration, actual_registered_bounds: record.actual_registered_bounds, high_res_sha256: record.high_res_sha256, source_sha256: record.source_sha256, mirror_sha256: record.mirror_sha256 }, null, 2));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
