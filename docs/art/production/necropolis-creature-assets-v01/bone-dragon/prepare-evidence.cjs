const { fs, path, root, sha, job, json, alphaBounds } = require('../tools/lib.cjs');

(async () => {
  const slug = 'bone-dragon';
  const dir = path.join(root, slug);
  const j = job(slug);
  const metadataPath = path.resolve(root, j.source_metadata);
  const originalPath = path.resolve(root, j.original_def);
  const metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
  const checks = {
    source_id: j.source_id === 'CNDRGN' && metadata.name === 'CNDRGN.def',
    metadata_sha256: sha(fs.readFileSync(metadataPath)) === j.source_metadata_sha256,
    original_def_sha256: sha(fs.readFileSync(originalPath)) === j.original_def_sha256,
    metadata_def_sha256: metadata.def_sha256 === j.original_def_sha256,
    all_native_group_records_match: JSON.stringify(metadata.groups) === JSON.stringify(j.groups.map(g => g.native)),
    native_idle_sha256: sha(fs.readFileSync(path.join(dir, 'native-idle.png'))) === j.source_idle_frame_sha256
  };
  if (Object.values(checks).some(x => !x)) throw Error(JSON.stringify(checks));
  const referenceFiles = ['job.json', 'native-idle.png', 'native-idle-6x.png', 'native-scale-guide.png', 'native-all-groups-contact.png', ...j.native_group_guides.map(x => path.basename(x))];
  const references = referenceFiles.map(file => ({ file, sha256: sha(fs.readFileSync(path.join(dir, file))) }));
  references.push({ file: '../references/pikeman-rendering-master.png', sha256: sha(fs.readFileSync(path.join(root, 'references/pikeman-rendering-master.png'))) });
  const groupInventory = j.groups.map(g => ({ id: g.id, block: g.block, role_format_mapping: g.role_format_mapping, role_visually_confirmed_in_job: g.role_visually_confirmed, frame_count: g.frame_count, distinct_indexed_drawings: g.distinct_indexed_drawings, native_frames: g.native.frames.map(f => ({ index: f.index, name: f.name, index_sha256: f.index_sha256 })), native_pages: g.native.pages }));
  const evidence = {
    source_id: j.source_id, metadata_path: j.source_metadata, original_def_path: j.original_def,
    metadata_sha256: j.source_metadata_sha256, original_def_sha256: j.original_def_sha256,
    checks, metadata_header: Object.fromEntries(Object.entries(metadata).filter(([k]) => k !== 'groups')),
    native_idle_frame: j.source_idle_frame, native_idle_bounds_alpha64: await alphaBounds(path.join(dir, 'native-idle.png'), 64),
    flipbooks: j.original_flipbooks, timeline_frames: j.original_timeline_frames, distinct_indexed_drawings: j.original_distinct_indexed_drawings,
    group_inventory: groupInventory, reference_hashes_before_work: references,
    source_authority: 'Original extracted CNDRGN pixels; user verified the Bone Dragon mapping. CBDRGN and CHDRGN excluded.',
    validation_boundary: 'Source bytes and static images only; no engine, animation generation or runtime validation.'
  };
  json(path.join(dir, 'source-evidence.json'), evidence);
  console.log(JSON.stringify({ checks, header: evidence.metadata_header, groups: groupInventory.map(({ id, block, role_format_mapping, frame_count, distinct_indexed_drawings }) => ({ id, block, role_format_mapping, frame_count, distinct_indexed_drawings })), native_idle_bounds: evidence.native_idle_bounds_alpha64 }, null, 2));
})().catch(error => { console.error(error); process.exitCode = 1; });
