const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const sharp = require('C:/Users/zhouc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root = path.resolve(__dirname, '..');
const repo = path.resolve(root, '../../../..');
const originalRoot = path.join(repo, 'docs/art/references/heroes3-original-flipbooks');
const artScratch = 'C:/Users/zhouc/.codex/visualizations/2026/09/08/01a07f41-7159-70f1-ac7d-e6217941c130';
const roster = [
  ['Skeleton', 'skeleton', 'CSKELE'],
  ['Skeleton Warrior', 'skeleton-warrior', 'CWSKEL'],
  ['Walking Dead', 'walking-dead', 'CZOMBI'],
  ['Zombie', 'zombie', 'CZOMLO'],
  ['Wight', 'wight', 'CWIGHT'],
  ['Wraith', 'wraith', 'CWRAIT'],
  ['Vampire', 'vampire', 'CVAMP'],
  ['Vampire Lord', 'vampire-lord', 'CNOSFE'],
  ['Lich', 'lich', 'CLICH'],
  ['Power Lich', 'power-lich', 'CPLICH'],
  ['Black Knight', 'black-knight', 'CBKNIG'],
  ['Dread Knight', 'dread-knight', 'CBLORD'],
  ['Bone Dragon', 'bone-dragon', 'CNDRGN'],
  ['Ghost Dragon', 'ghost-dragon', 'CHDRGN'],
];
const roles = {
  0: 'movement', 1: 'gesture / mouse-over', 2: 'idle', 3: 'hit reaction',
  4: 'defence', 5: 'death', 6: 'alternate death',
  7: 'turn', 8: 'turn', 9: 'turn', 10: 'turn',
  11: 'melee upper', 12: 'melee front', 13: 'melee lower',
  14: 'ranged upper', 15: 'ranged front', 16: 'ranged lower',
  17: 'special upper', 18: 'special front', 19: 'special lower',
  20: 'movement start', 21: 'movement end',
};
const scale = 180 / 73;
const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const relative = p => path.relative(root, p).replaceAll('\\', '/');
const json = (p, data) => fs.writeFileSync(p, JSON.stringify(data, null, 2) + '\n');
const label = (text, width, height, size = 18) => Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}"><text x="12" y="25" fill="#e8e6e0" font-size="${size}" font-family="Arial">${text.replaceAll('&', '&amp;')}</text></svg>`);

async function bounds(input, threshold = 64) {
  const { data, info } = await sharp(input).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let x0 = info.width, y0 = info.height, x1 = -1, y1 = -1;
  for (let y = 0; y < info.height; y++) for (let x = 0; x < info.width; x++) {
    if (data[(y * info.width + x) * 4 + 3] > threshold) {
      x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y);
    }
  }
  if (x1 < 0) throw Error('Empty reference');
  return { left: x0, top: y0, width: x1 - x0 + 1, height: y1 - y0 + 1, right: x1 + 1, bottom: y1 + 1 };
}

async function frame(srcDir, g, f) {
  const pg = g.pages[f.page];
  return sharp(path.join(srcDir, pg.preview)).extract({ left: f.x, top: f.y, width: g.cell_width, height: g.cell_height }).png().toBuffer();
}

(async () => {
  const refs = path.join(root, 'references'); fs.mkdirSync(refs, { recursive: true });
  const benchmarks = [
    ['pikeman-rendering-master.png', 'pikeman-sprite-assets-v01/pikeman_idle_master_rgba.png'],
    ['pikeman-registered-180px.png', 'pikeman-sprite-assets-v01/idle_right_frame_00.png'],
    ['swordsman-rendering-master.png', 'castle-creature-assets-v01/swordsman/master_rgba.png'],
  ];
  const benchmarkRecords = [];
  for (const [dest, original] of benchmarks) {
    const src = path.join(artScratch, original), out = path.join(refs, dest);
    if (fs.existsSync(out)) {
      if (sha(fs.readFileSync(out)) !== sha(fs.readFileSync(src))) throw Error('Benchmark changed: ' + dest);
    } else fs.copyFileSync(src, out);
    benchmarkRecords.push({ file: relative(out), sha256: sha(fs.readFileSync(out)), source_relative_to_art_scratch: original, role: 'approved generated rendering reference; not original Heroes III art' });
  }
  json(path.join(refs, 'benchmarks.json'), benchmarkRecords);
  const inventory = [], lineup = [], contacts = [];
  for (let i = 0; i < roster.length; i++) {
    const [name, slug, id] = roster[i], dir = path.join(root, slug), srcDir = path.join(originalRoot, 'sprites/H3sprite', id);
    fs.mkdirSync(dir, { recursive: true });
    const metadata = path.join(srcDir, 'metadata.json'), m = JSON.parse(fs.readFileSync(metadata, 'utf8'));
    const original = path.join(originalRoot, m.original);
    const originalHash = sha(fs.readFileSync(original));
    if (originalHash !== m.def_sha256) throw Error('DEF hash mismatch: ' + id);
    const idle = m.groups.find(g => g.id === 2), first = idle.frames[0], idlePNG = await frame(srcDir, idle, first);
    fs.writeFileSync(path.join(dir, 'native-idle.png'), idlePNG);
    const b = await bounds(idlePNG), crop = await sharp(idlePNG).extract(b).png().toBuffer();
    await sharp(crop).resize(b.width * 6, b.height * 6, { kernel: 'nearest' }).png().toFile(path.join(dir, 'native-idle-6x.png'));
    const refsForCreature = [], groupParts = [], tw = 410, th = 340;
    const everyFrame = m.groups.flatMap(g => g.frames);
    const sourceBounds = { left: Math.min(...everyFrame.map(f => f.left)), top: Math.min(...everyFrame.map(f => f.top)), right: Math.max(...everyFrame.map(f => f.left + f.width)), bottom: Math.max(...everyFrame.map(f => f.top + f.height)) };
    const mappedBounds = { left: 512 + (sourceBounds.left - 196) * scale, top: 512 + (sourceBounds.top - 268) * scale, right: 512 + (sourceBounds.right - 196) * scale, bottom: 512 + (sourceBounds.bottom - 268) * scale };
    const groups = [];
    for (let gi = 0; gi < m.groups.length; gi++) {
      const g = m.groups[gi], picks = [...new Set([0, Math.floor(g.frames.length / 2), g.frames.length - 1])];
      const groupRec = { id: g.id, block: g.block, role_format_mapping: roles[g.id] || 'unknown', role_visually_confirmed: false, frame_count: g.frames.length, distinct_indexed_drawings: new Set(g.frames.map(f => f.index_sha256)).size, native: g };
      groups.push(groupRec);
      const part = [], cw = 350, ch = 360;
      for (let pi = 0; pi < picks.length; pi++) {
        const f = g.frames[picks[pi]], png = await frame(srcDir, g, f), pb = await bounds(png);
        const fit = await sharp(png).extract(pb).resize(310, 295, { fit: 'inside', kernel: 'nearest' }).png().toBuffer();
        const fm = await sharp(fit).metadata();
        part.push({ input: fit, left: pi * cw + Math.floor((cw - fm.width) / 2), top: 40 + Math.floor((295 - fm.height) / 2) });
        part.push({ input: label('G' + g.id + ' F' + f.index + ' / ' + f.name, cw, ch, 15), left: pi * cw, top: 0 });
      }
      const gp = path.join(dir, `native-g${String(g.id).padStart(2, '0')}-guide.png`);
      await sharp({ create: { width: cw * picks.length, height: ch, channels: 4, background: '#22303b' } }).composite(part).png().toFile(gp);
      refsForCreature.push(relative(gp));
      const f = g.frames[Math.floor(g.frames.length / 2)], png = await frame(srcDir, g, f), pb = await bounds(png);
      const fit = await sharp(png).extract(pb).resize(tw - 32, th - 55, { fit: 'inside', kernel: 'nearest' }).png().toBuffer(), fm = await sharp(fit).metadata();
      const x = (gi % 4) * tw, y = Math.floor(gi / 4) * th;
      groupParts.push({ input: fit, left: x + Math.floor((tw - fm.width) / 2), top: y + 40 + Math.floor((th - 55 - fm.height) / 2) });
      groupParts.push({ input: label('G' + g.id + ': ' + g.frames.length + ' positions', tw, th), left: x, top: y });
    }
    await sharp({ create: { width: tw * 4, height: th * Math.ceil(groups.length / 4), channels: 4, background: '#14232f' } }).composite(groupParts).png().toFile(path.join(dir, 'native-all-groups-contact.png'));
    const target = { left: Math.round(512 + (b.left - 196) * scale), top: Math.round(512 + (b.top - 268) * scale), width: Math.round(b.width * scale), height: Math.round(b.height * scale) };
    const scaled = await sharp(crop).resize(target.width, target.height, { kernel: 'nearest' }).png().toBuffer();
    await sharp({ create: { width: 1024, height: 768, channels: 4, background: '#00000000' } }).composite([{ input: scaled, left: target.left, top: target.top }]).png().toFile(path.join(dir, 'native-scale-guide.png'));
    const job = { number: i + 1, name, slug, source_id: id, source_metadata: relative(metadata), source_metadata_sha256: sha(fs.readFileSync(metadata)), original_def: relative(original), original_def_sha256: originalHash, source_idle_frame: first, source_idle_bounds_alpha64: b, source_idle_frame_sha256: sha(idlePNG), target_master_alpha_bounds: target, cell: [1024, 768], anchor: [512, 512], original_reference: [196, 268], source_scale: scale, scale_authority: 'approved Pikeman calibration 180px standing body / 73px original reference', source_all_group_bounds: sourceBounds, mapped_all_group_bounds: mappedBounds, all_groups_fit_40px_padding: mappedBounds.left >= 40 && mappedBounds.top >= 40 && mappedBounds.right <= 984 && mappedBounds.bottom <= 728, original_flipbooks: groups.length, original_timeline_frames: groups.reduce((s, g) => s + g.frame_count, 0), original_distinct_indexed_drawings: new Set(everyFrame.map(f => f.index_sha256)).size, groups, reference_images: ['native-idle.png', 'native-idle-6x.png', 'native-scale-guide.png', 'native-all-groups-contact.png'], native_group_guides: refsForCreature, benchmark: '../references/pikeman-rendering-master.png', gate: 'master review only; no animation generation before user approval' };
    json(path.join(dir, 'job.json'), job);
    inventory.push({ number: i + 1, name, slug, source_id: id, original_flipbooks: job.original_flipbooks, original_timeline_frames: job.original_timeline_frames, original_distinct_indexed_drawings: job.original_distinct_indexed_drawings, original_def_sha256: originalHash, source_metadata_sha256: job.source_metadata_sha256, groups: groups.map(g => ({ id: g.id, block: g.block, frame_count: g.frame_count, distinct_indexed_drawings: g.distinct_indexed_drawings, format_role: g.role_format_mapping, visually_confirmed: false })), all_groups_fit_40px_padding: job.all_groups_fit_40px_padding });
    const preview = await sharp(crop).resize(target.width, target.height, { kernel: 'nearest' }).png().toBuffer();
    const x = (i % 4) * 360, y = Math.floor(i / 4) * 380;
    lineup.push({ input: preview, left: x + 180 + Math.round((b.left - 196) * scale), top: y + 325 + Math.round((b.top - 268) * scale) });
    lineup.push({ input: label((i + 1) + '. ' + name, 360, 380, 16), left: x, top: y });
  }
  await sharp({ create: { width: 1440, height: 1520, channels: 4, background: '#172431' } }).composite(lineup).png().toFile(path.join(root, 'original-roster-shared-scale.png'));
  json(path.join(root, 'source-inventory.json'), { status: 'verified local original files and metadata; artwork review tracked separately', source: '../../references/heroes3-original-flipbooks', roster: inventory, total_creatures: 14, total_groups: inventory.reduce((s, r) => s + r.original_flipbooks, 0), total_timeline_frames: inventory.reduce((s, r) => s + r.original_timeline_frames, 0), source_hashes_verified: true, all_originals_untouched: true, group_role_authority: 'VCMI creature animation format mapping; individual visual audit still required', group_role_reference: 'https://vcmi.eu/modders/Animation_Format/#creature-animation-groups', frame_timing_known: false, engine_imported: false });
  console.log(JSON.stringify(inventory.map(({ name, original_flipbooks, original_timeline_frames, all_groups_fit_40px_padding }) => ({ name, original_flipbooks, original_timeline_frames, all_groups_fit_40px_padding })), null, 2));
})().catch(error => { console.error(error); process.exitCode = 1; });
