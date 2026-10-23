'use strict';
// Mechanical extraction/placement of built-in-generated eye pixels only; no pixel repainting.
const assert = require('node:assert/strict');
const { fs, path, sharp, sha, json, label } = require('../tools/lib.cjs');
module.exports = async function repairEye() {
  const dir = __dirname;
  const basePath = path.join(dir, 'raw/attempt-02.png');
  const generatedPath = path.join(dir, 'raw/attempt-05.png');
  const outputPath = path.join(dir, 'master-input-eye-repair.png');
  const before = await sharp(basePath).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const meta = await sharp(generatedPath).metadata();
  assert.equal(meta.width / meta.height, 3 / 4, 'Head crop aspect ratio must be preserved');
  // Reduce only the generated accent art to approximately 10px near / 3px far,
  // then align inside the existing sockets; full-body registration never changes.
  const patchScale = 1.5, patchWidth = 135, patchHeight = 180;
  const eyeSource = await sharp(generatedPath).resize(patchWidth, patchHeight, { kernel: 'lanczos3' })
    .ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const out = Buffer.from(before.data), applied = new Set(), parts = [];
  for (const spec of [
    { name: 'near', region: [23, 21, 52, 48], center: [554, 285] },
    { name: 'far', region: [53, 20, 68, 40], center: [578, 280] }
  ]) {
    const pixels = [];
    for (let y = Math.floor(spec.region[1] * patchScale); y < Math.ceil(spec.region[3] * patchScale); y++) {
      for (let x = Math.floor(spec.region[0] * patchScale); x < Math.ceil(spec.region[2] * patchScale); x++) {
        const i = (y * patchWidth + x) * 4;
        const r = eyeSource.data[i], g = eyeSource.data[i + 1], b = eyeSource.data[i + 2];
        if (eyeSource.data[i + 3] > 240 && r > 60 && r > g * 1.9 && r > b * 1.5)
          pixels.push({ x, y, i });
      }
    }
    assert.ok(pixels.length > 1, 'Missing generated red accent: ' + spec.name);
    const bounds = {
      left: Math.min(...pixels.map(p => p.x)), right: Math.max(...pixels.map(p => p.x)),
      top: Math.min(...pixels.map(p => p.y)), bottom: Math.max(...pixels.map(p => p.y))
    };
    const dx = Math.round(spec.center[0] - (bounds.left + bounds.right) / 2);
    const dy = Math.round(spec.center[1] - (bounds.top + bounds.bottom) / 2);
    let copied = 0;
    for (const p of pixels) {
      const x = p.x + dx, y = p.y + dy;
      const q = (y * before.info.width + x) * 4;
      // Retain the original socket/bone boundary and alpha; accept only opaque dark socket pixels.
      if (before.data[q + 3] < 200 ||
          before.data[q] >= 115 || before.data[q + 1] >= 115 || before.data[q + 2] >= 115) continue;
      for (let c = 0; c < 3; c++) out[q + c] = eyeSource.data[p.i + c];
      applied.add(y * before.info.width + x);
      copied++;
    }
    assert.ok(copied > 1, 'No suitable original socket pixels: ' + spec.name);
    parts.push({ name: spec.name, generated_region: spec.region, generated_red_bounds: bounds,
      translation_to_original: [dx, dy], original_center: spec.center, copied_pixels: copied });
  }
  let changed = 0, outside = 0, alphaChanges = 0;
  const changedPoints = [];
  for (let p = 0; p < before.info.width * before.info.height; p++) {
    const i = p * 4;
    if (out[i + 3] !== before.data[i + 3]) alphaChanges++;
    if (out[i] !== before.data[i] || out[i + 1] !== before.data[i + 1] || out[i + 2] !== before.data[i + 2]) {
      changed++; if (!applied.has(p)) outside++;
      changedPoints.push([p % before.info.width, Math.floor(p / before.info.width)]);
    }
  }
  assert.equal(outside, 0);
  assert.equal(alphaChanges, 0);
  await sharp(out, { raw: { width: before.info.width, height: before.info.height, channels: 4 } })
    .png().toFile(outputPath);
  const record = {
    method: 'Only red pixels from built-in generated head edit; uniform 3:4 reduction and integer socket alignment; no new colors painted',
    base_file: 'raw/attempt-02.png', base_sha256: sha(fs.readFileSync(basePath)),
    generated_eye_source: 'raw/attempt-05.png', generated_eye_source_sha256: sha(fs.readFileSync(generatedPath)),
    generated_head_dimensions: [meta.width, meta.height], reduced_head_dimensions: [patchWidth, patchHeight],
    accent_scale_relative_to_base_crop: patchScale,
    base_head_crop: [515, 250, 90, 120],
    eye_parts: parts, changed_rgb_pixels: changed,
    changed_bounds: {
      left: Math.min(...changedPoints.map(p => p[0])), top: Math.min(...changedPoints.map(p => p[1])),
      right: Math.max(...changedPoints.map(p => p[0])) + 1, bottom: Math.max(...changedPoints.map(p => p[1])) + 1
    },
    changed_pixels_outside_eye_selection: outside, alpha_changes: alphaChanges,
    all_non_eye_pixels_equal_base: true,
    output_file: 'master-input-eye-repair.png', output_sha256: sha(fs.readFileSync(outputPath))
  };
  json(path.join(dir, 'eye-repair-provenance.json'), record);
  const native = await sharp(path.join(dir, '../references/native-power-lich-head-audit.png'))
    .resize(300, 410, { fit: 'inside', kernel: 'nearest' }).png().toBuffer();
  const originalHead = await sharp(basePath).extract({ left: 515, top: 250, width: 90, height: 120 })
    .resize(270, 360, { kernel: 'nearest' }).png().toBuffer();
  const finalHead = await sharp(outputPath).extract({ left: 515, top: 250, width: 90, height: 120 })
    .resize(270, 360, { kernel: 'nearest' }).png().toBuffer();
  await sharp({ create: { width: 1000, height: 500, channels: 4, background: '#1b2936' } })
    .composite([
      { input: native, left: 10, top: 60 },
      { input: originalHead, left: 355, top: 70 },
      { input: finalHead, left: 695, top: 70 },
      { input: label('Actual CPLICH native crop', 330, 50, 17), left: 0, top: 0 },
      { input: label('Before: red removed in error', 330, 50, 17), left: 335, top: 0 },
      { input: label('After: two red socket accents', 330, 50, 17), left: 670, top: 0 }
    ]).png().toFile(path.join(dir, 'eye-repair-review.png'));
  return record;
};
