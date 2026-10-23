const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const sharp = require('C:/Users/zhouc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root = path.resolve(__dirname, '..');
const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const json = (p, value) => fs.writeFileSync(p, JSON.stringify(value, null, 2) + '\n');
const job = slug => JSON.parse(fs.readFileSync(path.join(root, slug, 'job.json'), 'utf8'));
async function alphaBounds(input, threshold = 8) {
  const { data, info } = await sharp(input).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let x0 = info.width, y0 = info.height, x1 = -1, y1 = -1, transparent = 0, opaque = 0;
  for (let y = 0; y < info.height; y++) for (let x = 0; x < info.width; x++) {
    const a = data[(y * info.width + x) * 4 + 3];
    if (!a) transparent++; if (a > 200) opaque++;
    if (a > threshold) { x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y); }
  }
  if (x1 < 0) throw Error('Empty image');
  return { left: x0, top: y0, width: x1 - x0 + 1, height: y1 - y0 + 1, right: x1 + 1, bottom: y1 + 1, transparent_pixels: transparent, opaque_pixels: opaque };
}
const cropRect = b => ({ left: b.left, top: b.top, width: b.width, height: b.height });
const label = (text, width, height, size = 20, y = 30) => Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}"><text x="20" y="${y}" font-family="Arial" font-size="${size}" fill="#e9e7e0">${text.replaceAll('&', '&amp;').replaceAll('<', '&lt;')}</text></svg>`);

async function registerMaster(slug, input, provenance, options = {}) {
  const j = job(slug), dir = path.join(root, slug), meta = await sharp(input).metadata();
  if (!meta.hasAlpha) throw Error('Generated master must contain alpha');
  const b = await alphaBounds(input);
  if (!b.transparent_pixels) throw Error('Opaque background is not a usable master');
  const crop = options.crop || cropRect(b);
  const master = await sharp(input).extract(crop).png().toBuffer();
  fs.writeFileSync(path.join(dir, 'master_rgba.png'), master);
  const target = j.target_master_alpha_bounds;
  const h = options.visible_height || target.height;
  const w = Math.round(crop.width * h / crop.height);
  const x = options.left ?? Math.round(target.left + target.width / 2 - w / 2);
  const y = options.top ?? target.top + target.height - h;
  if (x < 40 || y < 40 || x + w > j.cell[0] - 40 || y + h > j.cell[1] - 40) throw Error('Master outside padding');
  const scaled = await sharp(master).resize(w, h, { kernel: 'lanczos3' }).png().toBuffer();
  const source = await sharp({ create: { width: j.cell[0], height: j.cell[1], channels: 4, background: '#00000000' } }).composite([{ input: scaled, left: x, top: y }]).png().toBuffer();
  const mirror = await sharp(source).flop().png().toBuffer();
  fs.writeFileSync(path.join(dir, 'master_source_1024x768.png'), source);
  fs.writeFileSync(path.join(dir, 'master_mirror_1024x768.png'), mirror);
  const rawSource = await sharp(source).ensureAlpha().raw().toBuffer(), rawMirror = await sharp(mirror).ensureAlpha().raw().toBuffer();
  for (let yy = 0; yy < j.cell[1]; yy++) for (let xx = 0; xx < j.cell[0]; xx++) for (let c = 0; c < 4; c++) {
    if (rawSource[(yy * j.cell[0] + xx) * 4 + c] !== rawMirror[(yy * j.cell[0] + j.cell[0] - 1 - xx) * 4 + c]) throw Error('Mirror mismatch');
  }
  const record = { name: j.name, slug, status: 'proposal; awaiting user master approval', artwork_method: 'built-in image generation; mechanical crop and aspect-preserving registration', cell: j.cell, anchor: j.anchor, original_reference: j.original_reference, source_scale: j.source_scale, target_native_bounds: target, actual_registered_bounds: await alphaBounds(source, 64), registration: { crop, width: w, height: h, left: x, top: y, method: 'uniform height scale, original idle silhouette center and bottom registration', options }, original_def_sha256: j.original_def_sha256, source_metadata_sha256: j.source_metadata_sha256, high_res_master: 'master_rgba.png', high_res_sha256: sha(master), source: 'master_source_1024x768.png', source_sha256: sha(source), mirror: 'master_mirror_1024x768.png', mirror_sha256: sha(mirror), generated_input_sha256: sha(fs.readFileSync(input)), transparent_background: true, exact_mirror_verified: true, mechanical_checks_only: true, visual_approval: false, animation_generated: false, engine_imported: false, provenance };
  json(path.join(dir, 'master-manifest.json'), record);
  const native = fs.readFileSync(path.join(dir, 'native-scale-guide.png'));
  const panes = [];
  for (const [i, png, title] of [[0, native, 'Original reference at shared scale'], [1, source, 'Generated master at shared scale']]) {
    const bb = await alphaBounds(png, 64), pp = await sharp(png).extract(cropRect(bb)).png().toBuffer();
    panes.push({ input: pp, left: i * 520 + 260 + bb.left - j.anchor[0], top: 380 + bb.top - j.anchor[1] });
    panes.push({ input: label(title, 520, 450, 18), left: i * 520, top: 0 });
  }
  const large = await sharp(master).resize(450, 570, { fit: 'inside', kernel: 'lanczos3' }).png().toBuffer(), lm = await sharp(large).metadata();
  panes.push({ input: large, left: 1100 + Math.floor((450 - lm.width) / 2), top: 55 + Math.floor((570 - lm.height) / 2) });
  panes.push({ input: label(j.name + ' - enlarged inspection', 500, 650, 18), left: 1060, top: 0 });
  await sharp({ create: { width: 1560, height: 680, channels: 4, background: '#1b2936' } }).composite(panes).png().toFile(path.join(dir, 'source-vs-master.png'));
  return record;
}
module.exports = { root, sharp, fs, path, sha, job, json, alphaBounds, cropRect, label, registerMaster };
