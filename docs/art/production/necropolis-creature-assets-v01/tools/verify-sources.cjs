const { fs, path, root, sharp, sha, json, alphaBounds } = require('./lib.cjs');
const inventory = JSON.parse(fs.readFileSync(path.join(root, 'source-inventory.json'), 'utf8'));
const failures = [], records = [];
const reportPath = path.join(root, 'source-verification.json');
const previous = fs.existsSync(reportPath) ? JSON.parse(fs.readFileSync(reportPath, 'utf8')) : null;
(async () => {
  let positions = 0, groups = 0, verifiedPixels = 0;
  for (const r of inventory.roster) {
    const dir = path.join(root, r.slug), j = JSON.parse(fs.readFileSync(path.join(dir, 'job.json'), 'utf8'));
    const metadata = path.resolve(root, j.source_metadata), original = path.resolve(root, j.original_def);
    const native = JSON.parse(fs.readFileSync(metadata, 'utf8'));
    if (sha(fs.readFileSync(metadata)) !== j.source_metadata_sha256) failures.push(r.slug + ' metadata changed');
    if (sha(fs.readFileSync(original)) !== native.def_sha256 || native.def_sha256 !== j.original_def_sha256) failures.push(r.slug + ' original DEF changed');
    if (JSON.stringify(j.groups.map(g => g.native)) !== JSON.stringify(native.groups)) failures.push(r.slug + ' incomplete or altered group metadata');
    const pages = [], srcDir = path.dirname(metadata);
    for (const g of native.groups) {
      groups++;
      for (let pi = 0; pi < g.pages.length; pi++) {
        const pg = g.pages[pi], previewPath = path.join(srcDir, pg.preview), indexedPath = path.join(srcDir, pg.indexed);
        const p = await sharp(previewPath).metadata(), indexed = await sharp(indexedPath).metadata();
        if (p.width !== pg.width || p.height !== pg.height || indexed.width !== pg.width || indexed.height !== pg.height) failures.push(`${r.slug} G${g.id} page size`);
        pages.push({ group: g.id, page: pi, preview: path.relative(root, previewPath).replaceAll('\\', '/'), preview_sha256: sha(fs.readFileSync(previewPath)), indexed: path.relative(root, indexedPath).replaceAll('\\', '/'), indexed_sha256: sha(fs.readFileSync(indexedPath)) });
      }
      for (const f of g.frames) {
        const pg = g.pages[f.page];
        if (f.x < 0 || f.y < 0 || f.x + g.cell_width > pg.width || f.y + g.cell_height > pg.height) failures.push(`${r.slug} G${g.id} F${f.index} cell bounds`);
        const rgba = await sharp(path.join(srcDir, pg.preview)).extract({ left: f.x, top: f.y, width: g.cell_width, height: g.cell_height }).png().toBuffer();
        const b = await alphaBounds(rgba, 0);
        if (!b.width || !b.height) failures.push(`${r.slug} G${g.id} F${f.index} empty`);
        verifiedPixels += g.cell_width * g.cell_height;
        positions++;
      }
    }
    records.push({ slug: r.slug, source_id: r.source_id, def_sha256: j.original_def_sha256, metadata_sha256: j.source_metadata_sha256, groups: native.groups.length, timeline_positions: native.groups.reduce((s, g) => s + g.frames.length, 0), preservation_pages: pages, original_reference: j.original_reference, mapped_bounds: j.mapped_all_group_bounds, original_frame_offsets_and_records_retained: true, all_groups_fit_40px_padding: j.all_groups_fit_40px_padding });
    if (!j.all_groups_fit_40px_padding) failures.push(r.slug + ' source bounds outside proposed canvas');
  }
  if (groups !== 228 || positions !== 1378) failures.push('Total mismatch');
  if (previous) {
    for (const r of records) {
      const prior = previous.records.find(p => p.slug === r.slug);
      if (!prior || JSON.stringify(prior.preservation_pages) !== JSON.stringify(r.preservation_pages)) failures.push(r.slug + ' original PNG pages changed since initial source verification');
    }
  }
  const report = { status: failures.length ? 'failed' : 'passed source availability and preservation checks', verification: 'DEF/metadata hash identity; complete metadata deep equality; every original timeline cell decoded from local preview sheets and checked nonempty/in bounds; indexed page presence, dimensions and hashes retained', source_creatures: records.length, source_groups: groups, source_timeline_cells: positions, decoded_cell_pixels: verifiedPixels, compared_with_previous_source_check: Boolean(previous), previous_check_sha256: previous ? sha(fs.readFileSync(reportPath)) : null, original_png_pages_unchanged_since_previous_check: previous ? !failures.some(f => f.includes('PNG pages changed')) : null, failures, records, limits: ['Not a fresh DEF decoder comparison; original extraction verifier remains separate.', 'PNG transparency and shadows follow the existing extraction interpretation.', 'Pixel decode does not establish visual review of all animation motion.', 'No original engine timing or root-motion interpretation established.', 'No gameplay, editor, engine import or runtime run.'], checked_at: new Date().toISOString() };
  json(reportPath, report);
  console.log(JSON.stringify({ creatures: records.length, groups, positions, failures }));
  if (failures.length) process.exitCode = 1;
})().catch(e => { console.error(e); process.exitCode = 1; });
