const { root, fs, path, sharp, sha, json, alphaBounds } = require('../tools/lib.cjs');

async function main() {
  const dir = path.join(root, 'skeleton');
  const source = fs.readFileSync(path.join(dir, 'master_source_1024x768.png'));
  const master = fs.readFileSync(path.join(dir, 'master_rgba.png'));
  const b = await alphaBounds(source, 64);
  const cellCrop = await sharp(source).extract({ left: b.left - 20, top: b.top - 20, width: b.width + 40, height: b.height + 40 }).png().toBuffer();
  const large = await sharp(master).resize({ width: 320, height: 520, fit: 'inside', kernel: 'lanczos3' }).png().toBuffer();
  const lm = await sharp(large).metadata();
  const cm = await sharp(cellCrop).metadata();
  const panes = [];
  for (const [i, background] of ['#e3e1da', '#1b2936'].entries()) {
    panes.push({ input: await sharp(large).flatten({ background }).png().toBuffer(), left: i * 500 + Math.round((320 - lm.width) / 2), top: 20 });
    panes.push({ input: await sharp(cellCrop).flatten({ background }).png().toBuffer(), left: i * 500 + 340, top: 20 });
    panes.push({ input: await sharp({ create: { width: 500, height: 560, channels: 4, background } }).png().toBuffer(), left: i * 500, top: 0 });
  }
  // Background tiles must precede the unmodified review crops.
  const ordered = [panes[2], panes[5], panes[0], panes[1], panes[3], panes[4]];
  const review = await sharp({ create: { width: 1000, height: 560, channels: 4, background: '#e3e1da' } }).composite(ordered).png().toBuffer();
  fs.writeFileSync(path.join(dir, 'alpha-review.png'), review);
  const provenance = JSON.parse(fs.readFileSync(path.join(dir, 'generation-provenance.json')));
  const manifest = JSON.parse(fs.readFileSync(path.join(dir, 'master-manifest.json')));
  console.log(JSON.stringify({ raw_dimensions: { width: provenance.attempts[0].generated_metadata.width, height: provenance.attempts[0].generated_metadata.height }, alpha_review_sha256: sha(review), master_sha256: manifest.high_res_sha256, source_sha256: manifest.source_sha256, mirror_sha256: manifest.mirror_sha256, game_crop_dimensions: [cm.width, cm.height], source_alpha: await alphaBounds(source, 64), groups: provenance.source_evidence.native_groups }, null, 2));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
