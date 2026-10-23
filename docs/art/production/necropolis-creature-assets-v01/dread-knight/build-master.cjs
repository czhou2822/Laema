// Static artwork registration and review exports only; no engine operations.
const {
  root, sharp, fs, path, sha, job, json, alphaBounds, cropRect, registerMaster
} = require('../tools/lib.cjs');

const slug = 'dread-knight';
const dir = __dirname;
const j = job(slug);
const output = name => {
  const p = path.resolve(dir, name);
  if (!p.startsWith(dir + path.sep)) throw Error('Output outside assigned folder');
  return p;
};
const relative = p => path.relative(root, p).replaceAll('\\', '/');
const digest = p => sha(fs.readFileSync(p));
const promptText = name => fs.readFileSync(output(name), 'utf8').replace(/\r\n/g, '\n').trimEnd();

const attemptSpecs = [
  {
    id: 'v01', prompt: 'prompt-master-v01.txt', raw: 'raw-master-v01.png',
    origin: 'C:/Users/zhouc/.codex/generated_images/01a1638e-579c-7601-b05f-5c0b568e0023/exec-6525df6f-c8b5-48a3-a625-d27c6ecad4de.png',
    refs: ['native-idle-6x.png', 'native-g02-guide.png', 'native-g12-guide.png', '../references/pikeman-rendering-master.png'],
    disposition: 'superseded: warm gold spike/trim treatment, invented horse chest spike and blade barbs'
  },
  {
    id: 'v02', prompt: 'prompt-master-v02-edit.txt', raw: 'raw-master-v02.png',
    origin: 'C:/Users/zhouc/.codex/generated_images/01a1638e-579c-7601-b05f-5c0b568e0023/exec-e4025d40-5849-420c-813f-661b27a31c97.png',
    refs: ['raw-master-v01.png', 'native-idle-6x.png', 'native-g02-guide.png', '../references/pikeman-rendering-master.png'],
    disposition: 'selected static proposal; human master approval pending'
  }
];

function immutableSources() {
  const metadata = path.resolve(root, j.source_metadata);
  const sourceDir = path.dirname(metadata);
  const paths = [
    output('job.json'),
    ...fs.readdirSync(dir).filter(f => /^native-.*\.png$/.test(f)).map(f => output(f)),
    path.resolve(root, 'worker-brief.md'), path.resolve(root, 'tools/lib.cjs'),
    path.resolve(root, '../..', 'ART_DIRECTION.md'),
    path.resolve(root, 'references/pikeman-rendering-master.png'),
    path.resolve(root, 'black-knight/native-idle-6x.png'),
    metadata, path.resolve(root, j.original_def), path.join(sourceDir, 'palette.rgb'),
    ...j.groups.flatMap(g => g.native.pages.flatMap(p => [
      path.join(sourceDir, p.preview), path.join(sourceDir, p.indexed)
    ]))
  ];
  return [...new Set(paths)].map(p => ({ path: relative(p), sha256: digest(p) }));
}

function verifySources(audit) {
  for (const entry of audit.immutable_sources) {
    if (digest(path.resolve(root, entry.path)) !== entry.sha256) {
      throw Error('Source changed: ' + entry.path);
    }
  }
}

async function alphaStats(p) {
  const { data, info } = await sharp(p).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let zero = 0, partial = 0, full = 0, borderNonzero = 0;
  const mask = new Uint8Array(info.width * info.height);
  for (let y = 0; y < info.height; y++) for (let x = 0; x < info.width; x++) {
    const n = y * info.width + x, a = data[n * 4 + 3];
    if (a === 0) zero++; else if (a === 255) full++; else partial++;
    if (a > 0 && (x === 0 || y === 0 || x === info.width - 1 || y === info.height - 1)) borderNonzero++;
    if (a > 64) mask[n] = 1;
  }
  const stack = new Int32Array(mask.length), components = [];
  for (let seed = 0; seed < mask.length; seed++) {
    if (!mask[seed]) continue;
    let length = 0, count = 0, x0 = info.width, y0 = info.height, x1 = -1, y1 = -1;
    stack[length++] = seed; mask[seed] = 0;
    while (length) {
      const n = stack[--length], y = Math.floor(n / info.width), x = n % info.width;
      count++; x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y);
      for (let dy = -1; dy <= 1; dy++) for (let dx = -1; dx <= 1; dx++) {
        const xx = x + dx, yy = y + dy;
        if (xx < 0 || yy < 0 || xx >= info.width || yy >= info.height) continue;
        const nn = yy * info.width + xx;
        if (mask[nn]) { mask[nn] = 0; stack[length++] = nn; }
      }
    }
    components.push({ pixels: count, bounds: { left: x0, top: y0, width: x1 - x0 + 1, height: y1 - y0 + 1 } });
  }
  components.sort((a, b) => b.pixels - a.pixels);
  return {
    width: info.width, height: info.height, channels: info.channels,
    zero_alpha_pixels: zero, partial_alpha_pixels: partial, full_alpha_pixels: full,
    border_nonzero_pixels: borderNonzero,
    bounds_alpha0: await alphaBounds(p, 0), bounds_alpha8: await alphaBounds(p, 8),
    bounds_alpha64: await alphaBounds(p, 64),
    connected_components_alpha64: components
  };
}

async function makeReviewBoard() {
  // These backgrounds and labels are inspection aids, never usable-art pixels.
  const viewport = { left: 430, top: 235, width: 280, height: 300 };
  const source = await sharp(output('master_source_1024x768.png')).extract(viewport).png().toBuffer();
  const native = await sharp(output('native-scale-guide.png')).extract(viewport).png().toBuffer();
  const mirror = await sharp(source).flop().png().toBuffer();
  const { data, info } = await sharp(source).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const mask = Buffer.alloc(info.width * info.height * 4);
  for (let n = 0; n < info.width * info.height; n++) {
    mask[n * 4] = mask[n * 4 + 1] = mask[n * 4 + 2] = data[n * 4 + 3];
    mask[n * 4 + 3] = 255;
  }
  const alpha = await sharp(mask, { raw: { width: info.width, height: info.height, channels: 4 } }).png().toBuffer();
  const specs = [
    ['Native / shared scale', '#1b2936', native],
    ['Proposal / shared scale', '#1b2936', source],
    ['Proposal / pale backdrop', '#dcdcd4', source],
    ['Proposal / alpha checker', 'checker', source],
    ['Exact mirror / shared scale', '#1b2936', mirror],
    ['Alpha channel / 1:1 pixels', '#000000', alpha]
  ];
  const parts = [];
  for (let i = 0; i < specs.length; i++) {
    const [title, bg, png] = specs[i];
    let rects = `<rect width="320" height="360" fill="${bg === 'checker' ? '#999999' : bg}"/>`;
    if (bg === 'checker') {
      for (let y = 0; y < 360; y += 12) for (let x = 0; x < 320; x += 12) {
        if ((x / 12 + y / 12) % 2) rects += `<rect x="${x}" y="${y}" width="12" height="12" fill="#c5c5c5"/>`;
      }
    }
    const fg = bg === '#dcdcd4' || bg === 'checker' ? '#111111' : '#eeeeee';
    const svg = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="320" height="360">${rects}<text x="12" y="24" font-family="Arial" font-size="16" fill="${fg}">${title}</text></svg>`);
    const panel = await sharp(svg).composite([{ input: png, left: 20, top: 42 }]).png().toBuffer();
    parts.push({ input: panel, left: (i % 3) * 320, top: Math.floor(i / 3) * 360 });
  }
  await sharp({ create: { width: 960, height: 720, channels: 4, background: '#111111' } })
    .composite(parts).png().toFile(output('game-size-alpha-review.png'));
}

async function main() {
  if (process.argv.includes('--verify')) {
    const audit = JSON.parse(fs.readFileSync(output('source-audit.json'), 'utf8'));
    verifySources(audit);
    const provenance = JSON.parse(fs.readFileSync(output('generation-record.json'), 'utf8'));
    for (const a of provenance.attempts) {
      if (digest(output(a.raw_file)) !== a.raw_sha256) throw Error('Raw changed: ' + a.raw_file);
      if (sha(promptText(a.exact_prompt_file)) !== a.exact_prompt_sha256) throw Error('Prompt changed: ' + a.exact_prompt_file);
    }
    console.log(JSON.stringify({ immutable_sources_unchanged: true, preserved_raws_and_prompts_unchanged: true, checked_sources: audit.immutable_sources.length }));
    return;
  }
  const mpath = path.resolve(root, j.source_metadata);
  const metadata = JSON.parse(fs.readFileSync(mpath, 'utf8'));
  if (digest(mpath) !== j.source_metadata_sha256 || digest(path.resolve(root, j.original_def)) !== j.original_def_sha256) throw Error('Original hash mismatch');
  if (JSON.stringify(metadata.groups) !== JSON.stringify(j.groups.map(g => g.native))) throw Error('Job differs from native metadata');
  const audit = {
    schema: 1, source_id: j.source_id, metadata_hash_matches_job: true, def_hash_matches_job: true,
    complete_native_groups_equal_job: true,
    original_groups: metadata.groups.length,
    original_frame_positions: metadata.groups.reduce((n, g) => n + g.frames.length, 0),
    original_distinct_indexed_drawings: new Set(metadata.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size,
    immutable_sources: immutableSources()
  };
  json(output('source-audit.json'), audit);
  const attempts = [];
  for (const spec of attemptSpecs) {
    const rawHash = digest(output(spec.raw));
    if (rawHash !== digest(spec.origin)) throw Error('Preserved raw differs from tool output');
    const exactPrompt = promptText(spec.prompt);
    attempts.push({
      id: spec.id, tool: 'image_gen.imagegen', execution: 'built-in image workflow',
      exact_prompt_file: spec.prompt, exact_prompt_sha256: sha(exactPrompt),
      prompt_normalization: 'UTF-8; LF; no trailing newline, identical to tool prompt argument',
      tool_arguments: {
        prompt: exactPrompt,
        referenced_image_paths: spec.refs.map(f => path.resolve(dir, f).replaceAll('\\', '/')),
        transparent_background: true
      },
      references: spec.refs.map(f => ({ path: f, sha256: digest(path.resolve(dir, f)) })),
      original_tool_output_path: spec.origin, raw_file: spec.raw, raw_sha256: rawHash,
      raw_preserved_byte_for_byte: true, raw_alpha: await alphaStats(output(spec.raw)),
      disposition: spec.disposition
    });
  }
  json(output('generation-record.json'), {
    schema: 1, name: j.name, slug, selected_attempt: 'v02',
    status: 'static master proposal; awaiting human approval',
    attempts, animation_generated: false, engine_imported: false, runtime_verified: false
  });
  const selected = attempts[1];
  const record = await registerMaster(slug, output(selected.raw_file), {
    tool: selected.tool, exact_prompt_file: selected.exact_prompt_file,
    exact_prompt_sha256: selected.exact_prompt_sha256,
    raw_file: selected.raw_file, raw_sha256: selected.raw_sha256,
    original_tool_output_path: selected.original_tool_output_path,
    generation_record: 'generation-record.json', source_audit: 'source-audit.json',
    inspected_native_guides: [0, 1, 2, 3, 4, 5, 7, 11, 12, 13, 17],
    primary_pose: 'CBLORD G2 F0 cblord62.pcx, original right-facing idle',
    rendering_reference: '../references/pikeman-rendering-master.png',
    rendering_reference_role: 'modeled volume and material finish only',
    corrected_from_v01: ['pale silver metal spikes and armor edging', 'removed invented horse chest spike', 'smooth single curved saber without barbs'],
    human_approval: false
  });
  await sharp(output('master_rgba.png')).extend({ top: 128, bottom: 128, left: 128, right: 128, background: '#00000000' })
    .png().toFile(output('master-padded-review.png'));
  await makeReviewBoard();
  const registeredAlpha = await alphaStats(output('master_source_1024x768.png'));
  const bb = registeredAlpha.bounds_alpha64;
  const minimumPadding = Math.min(bb.left, bb.top, j.cell[0] - bb.right, j.cell[1] - bb.bottom);
  if (minimumPadding < 40 || registeredAlpha.border_nonzero_pixels !== 0) throw Error('Registered padding failure');
  const ratioOriginal = j.source_idle_bounds_alpha64.width / j.source_idle_bounds_alpha64.height;
  const ratioGenerated = record.registration.crop.width / record.registration.crop.height;
  json(output('registration-checks.json'), {
    schema: 1, check_type: 'mechanical image export only; no game/engine/test execution',
    cell: j.cell, anchor: j.anchor, original_reference: j.original_reference,
    source_scale: j.source_scale, formula: '180/73',
    native_idle_bounds: j.source_idle_bounds_alpha64,
    target_bounds: j.target_master_alpha_bounds, registration: record.registration,
    anatomy_scale_override: false, independent_width_or_height_normalization: false,
    native_silhouette_aspect_ratio: ratioOriginal, generated_silhouette_aspect_ratio: ratioGenerated,
    silhouette_aspect_ratio_difference_percent: (ratioGenerated / ratioOriginal - 1) * 100,
    registered_alpha: registeredAlpha, minimum_visible_padding_px: minimumPadding,
    exact_mirror_verified: record.exact_mirror_verified,
    source_sha256: record.source_sha256, mirror_sha256: record.mirror_sha256,
    review_images: ['source-vs-master.png', 'game-size-alpha-review.png', 'master-padded-review.png'],
    note: 'A silhouette ratio is a mechanical check, not proof of anatomical or artistic equivalence.'
  });
  verifySources(audit);
  console.log(JSON.stringify({
    selected: selected.raw_file, raw_sha256: selected.raw_sha256,
    registration: record.registration, actual_bounds: record.actual_registered_bounds,
    minimum_padding: minimumPadding, exact_mirror_verified: record.exact_mirror_verified,
    source_files_unchanged: audit.immutable_sources.length,
    components_alpha64: registeredAlpha.connected_components_alpha64,
    aspect_ratio_difference_percent: (ratioGenerated / ratioOriginal - 1) * 100
  }, null, 2));
}

main().catch(error => { console.error(error.message); process.exitCode = 1; });
