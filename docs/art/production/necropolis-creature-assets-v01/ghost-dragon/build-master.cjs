const { root, sharp, fs, path, job, json, sha, alphaBounds, cropRect, label, registerMaster } = require('../tools/lib.cjs');

const slug = 'ghost-dragon';
const dir = path.join(root, slug);
const read = p => fs.readFileSync(p);
const rel = p => path.relative(dir, p).replaceAll('\\', '/');
const fileRecord = p => ({ file: rel(p), bytes: fs.statSync(p).size, sha256: sha(read(p)) });
const input = path.join(dir, 'raw/001-master.png');
const originalToolPath = 'C:/Users/zhouc/.codex/generated_images/01a16392-8fa8-75d3-840c-cfbddb652c56/exec-3ab4e61c-9065-4b07-9e8d-817a24f7a5c0.png';

async function preview(p, background, output) {
  await sharp(p).flatten({ background }).png().toFile(path.join(dir, output));
}

async function main() {
  const j = job(slug);
  const metaPath = path.resolve(root, j.source_metadata);
  const defPath = path.resolve(root, j.original_def);
  const sourceMeta = JSON.parse(read(metaPath));
  const hashes = { metadata: sha(read(metaPath)), original_def: sha(read(defPath)), idle: sha(read(path.join(dir, 'native-idle.png'))) };
  if (sourceMeta.name !== 'CHDRGN.def' || hashes.metadata !== j.source_metadata_sha256 || hashes.original_def !== j.original_def_sha256 || hashes.idle !== j.source_idle_frame_sha256) {
    throw Error('Source identity or hash mismatch');
  }
  if (sourceMeta.groups.length !== j.original_flipbooks || sourceMeta.frame_count !== j.original_timeline_frames) throw Error('Source coverage mismatch');
  for (const g of j.groups) {
    const s = sourceMeta.groups.find(v => v.id === g.id && v.block === g.block);
    if (!s || JSON.stringify(s) !== JSON.stringify(g.native)) throw Error('Job/native metadata mismatch at group ' + g.id);
  }
  const rawMeta = await sharp(input).metadata();
  const b0 = await alphaBounds(input, 0), b8 = await alphaBounds(input, 8), b64 = await alphaBounds(input, 64);
  const provenance = {
    tool: 'image_gen.imagegen',
    execution_path: 'built-in image generation only',
    attempt: 1,
    selected_raw: 'raw/001-master.png',
    prompt_file: 'prompts/001-master.txt',
    prompt_sha256: sha(read(path.join(dir, 'prompts/001-master.txt'))),
    request_file: 'prompts/001-request.json',
    request_sha256: sha(read(path.join(dir, 'prompts/001-request.json'))),
    original_tool_output_path: originalToolPath,
    raw_sha256: sha(read(input)),
    input_reference_roles: [
      { file: 'native-idle-6x.png', role: 'authoritative identity, native idle pose and source colors' },
      { file: 'native-g02-guide.png', role: 'supporting native idle anatomy' },
      { file: '../references/pikeman-rendering-master.png', role: 'approved modeled-volume rendering only' }
    ],
    no_manual_repainting: true,
    status: 'proposal; human approval required before animation'
  };
  const record = await registerMaster(slug, input, provenance);
  const registered = path.join(dir, record.source);
  const mirrored = path.join(dir, record.mirror);
  const rgba = path.join(dir, record.high_res_master);
  const cutoutMeta = await sharp(rgba).metadata();
  await sharp({ create: { width: cutoutMeta.width + 256, height: cutoutMeta.height + 256, channels: 4, background: '#00000000' } })
    .composite([{ input: rgba, left: 128, top: 128 }]).png().toFile(path.join(dir, 'master_padded_rgba.png'));
  await preview(input, '#253440', 'raw/001-master-on-dark.png');
  await preview(rgba, '#253440', 'master-inspection-dark.png');
  await preview(registered, '#253440', 'master-game-size-dark.png');
  await preview(registered, '#eee9df', 'master-game-size-light.png');
  await preview(mirrored, '#253440', 'master-mirror-game-size-dark.png');

  // Preview composites preserve the registered artwork bytes; they are not new artwork.
  const sources = [path.join(dir, 'native-scale-guide.png'), registered];
  const paneW = 410, paneH = 380, originX = 178, originY = 337;
  const items = [];
  for (let i = 0; i < sources.length; i++) {
    const png = sources[i], b = await alphaBounds(png, 64);
    const cut = await sharp(png).extract(cropRect(b)).png().toBuffer();
    items.push({ input: cut, left: i * paneW + originX + b.left - j.anchor[0], top: originY + b.top - j.anchor[1] });
    items.push({ input: label(i ? 'Generated master - 1:1 display scale' : 'Native reference - shared 180/73 scale', paneW, 40, 16, 27), left: i * paneW, top: 0 });
  }
  await sharp({ create: { width: paneW * 2, height: paneH, channels: 4, background: '#253440' } }).composite(items).png().toFile(path.join(dir, 'game-size-comparison.png'));

  // Compare binary alpha silhouettes at identical cell coordinates on separate panes.
  const silhouette = async p => {
    const a = await sharp(p).ensureAlpha().extractChannel(3).threshold(64).toBuffer();
    return sharp({ create: { width: j.cell[0], height: j.cell[1], channels: 3, background: '#dfe6ed' } }).joinChannel(a).png().toBuffer();
  };
  const alphaPanes = [];
  for (let i = 0; i < sources.length; i++) {
    const b = await alphaBounds(sources[i], 64);
    const cut = await sharp(await silhouette(sources[i])).extract(cropRect(b)).png().toBuffer();
    alphaPanes.push({ input: cut, left: i * paneW + originX + b.left - j.anchor[0], top: originY + b.top - j.anchor[1] });
    alphaPanes.push({ input: label(i ? 'Master alpha >64' : 'Native alpha >64', paneW, 40, 16, 27), left: i * paneW, top: 0 });
  }
  await sharp({ create: { width: paneW * 2, height: paneH, channels: 4, background: '#253440' } }).composite(alphaPanes).png().toFile(path.join(dir, 'source-vs-master-alpha.png'));

  const alphaPreview = await sharp(rgba).extractChannel(3).png().toBuffer();
  await sharp(alphaPreview).png().toFile(path.join(dir, 'master-alpha.png'));
  const { data, info } = await sharp(input).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const alphaCounts = { zero: 0, partial: 0, opaque: 0, edge_nonzero: 0, edge_max_alpha: 0 };
  for (let y = 0; y < info.height; y++) for (let x = 0; x < info.width; x++) {
    const a = data[(y * info.width + x) * 4 + 3];
    if (a === 0) alphaCounts.zero++; else if (a === 255) alphaCounts.opaque++; else alphaCounts.partial++;
    if (x === 0 || y === 0 || x === info.width - 1 || y === info.height - 1) {
      if (a) alphaCounts.edge_nonzero++;
      alphaCounts.edge_max_alpha = Math.max(alphaCounts.edge_max_alpha, a);
    }
  }
  const refs = ['job.json','native-idle.png','native-idle-6x.png','native-scale-guide.png','native-all-groups-contact.png',
    ...j.native_group_guides.map(p => path.basename(p)), '../references/pikeman-rendering-master.png',
    '../bone-dragon/native-idle-6x.png', '../worker-brief.md', '../tools/lib.cjs'].map(p => path.resolve(dir, p));
  const referenceInventory = refs.map(fileRecord);
  referenceInventory.push(fileRecord(metaPath), fileRecord(defPath));
  const promptRequest = JSON.parse(read(path.join(dir, 'prompts/001-request.json')));
  const toolReceipt = {
    tool: provenance.tool, exact_request_file: 'prompts/001-request.json',
    exact_prompt_in_request: promptRequest.prompt, raw_copy: fileRecord(input),
    original_tool_output_path: originalToolPath,
    original_output_matches_copy: fs.existsSync(originalToolPath) ? sha(read(originalToolPath)) === sha(read(input)) : null,
    attempts: 1, targeted_art_edits: 0, selected_attempt: 1,
    raw_metadata: { width: rawMeta.width, height: rawMeta.height, format: rawMeta.format, channels: rawMeta.channels, hasAlpha: rawMeta.hasAlpha }
  };
  json(path.join(dir, 'generation-provenance.json'), { ...toolReceipt, references: referenceInventory });
  const metrics = {
    source_identity: sourceMeta.name, source_hashes_verified: hashes,
    native_groups: sourceMeta.groups.map(g => ({ id: g.id, block: g.block, timeline_frames: g.frames.length, unique_indexed_drawings: new Set(g.frames.map(f => f.index_sha256)).size })),
    total_groups: sourceMeta.groups.length, timeline_frames: sourceMeta.frame_count,
    distinct_indexed_drawings: new Set(sourceMeta.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size,
    raw_bounds_alpha0: b0, raw_bounds_alpha8: b8, raw_bounds_alpha64: b64, raw_alpha: alphaCounts,
    raw_canvas: [rawMeta.width, rawMeta.height],
    raw_margins_alpha8: { left: b8.left, top: b8.top, right: rawMeta.width - b8.right, bottom: rawMeta.height - b8.bottom },
    registered_bounds_alpha0: await alphaBounds(registered, 0),
    registered_bounds_alpha8: await alphaBounds(registered, 8),
    registered_bounds_alpha64: record.actual_registered_bounds,
    registered_margins_alpha64: { left: record.actual_registered_bounds.left, top: record.actual_registered_bounds.top, right: j.cell[0] - record.actual_registered_bounds.right, bottom: j.cell[1] - record.actual_registered_bounds.bottom },
    target_native_bounds: j.target_master_alpha_bounds,
    width_delta_alpha64: record.actual_registered_bounds.width - j.target_master_alpha_bounds.width,
    registration: record.registration,
    no_aspect_stretch: true, registration_override: false,
    mirror_exact_verified_by_shared_helper: record.exact_mirror_verified,
    preserved_original_alpha: true, no_drawn_alpha_repairs: true,
    alpha_crop_limit: 'Shared helper crops to the >8 alpha bounds; faint outer raw pixels remain recoverable in the untouched raw.',
    tool_result_original_still_retained: fs.existsSync(originalToolPath),
    output_files: ['master_rgba.png','master_padded_rgba.png','master_source_1024x768.png','master_mirror_1024x768.png','source-vs-master.png',
      'master-inspection-dark.png','master-game-size-dark.png','master-game-size-light.png','master-mirror-game-size-dark.png',
      'game-size-comparison.png','source-vs-master-alpha.png','master-alpha.png'].map(p => fileRecord(path.join(dir, p)))
  };
  json(path.join(dir, 'mechanical-review.json'), metrics);
  console.log(JSON.stringify({ selected: provenance.selected_raw, raw_canvas: metrics.raw_canvas, raw_bounds_alpha8: b8,
    source: record.source, registered_bounds: record.actual_registered_bounds, registration: record.registration,
    alpha: alphaCounts, source_hashes_verified: true, exact_mirror: record.exact_mirror_verified }, null, 2));
}

main().catch(e => { console.error(e.stack || e); process.exitCode = 1; });
