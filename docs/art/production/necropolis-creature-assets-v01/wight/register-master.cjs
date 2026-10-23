const { root, sharp, fs, path, job, sha, alphaBounds, registerMaster } = require('../tools/lib.cjs');

const slug = 'wight';
const dir = path.join(root, slug);

async function main() {
  if (process.argv[2] === '--inspect') {
    const j = job(slug);
    const metadataPath = path.resolve(root, j.source_metadata);
    const native = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
    const imageFiles = process.argv.slice(3);
    const images = [];
    for (const file of imageFiles) {
      const resolved = path.resolve(dir, file);
      const metadata = await sharp(resolved).metadata();
      images.push({ file, width: metadata.width, height: metadata.height, channels: metadata.channels, has_alpha: metadata.hasAlpha, sha256: sha(fs.readFileSync(resolved)), alpha_bounds_8: await alphaBounds(resolved, 8), alpha_bounds_64: await alphaBounds(resolved, 64) });
    }
    console.log(JSON.stringify({
      native_metadata: { name: native.name, archive: native.archive, type: native.type, category: native.category, header_width: native.header_width, header_height: native.header_height, sha256: sha(fs.readFileSync(metadataPath)), groups_identical_to_job: JSON.stringify(native.groups) === JSON.stringify(j.groups.map(g => g.native)), groups: j.groups.map(g => ({ id: g.id, role_format_mapping: g.role_format_mapping, frame_count: g.frame_count, distinct_indexed_drawings: g.distinct_indexed_drawings })) },
      images
    }, null, 2));
    return;
  }
  const provenance = JSON.parse(fs.readFileSync(path.join(dir, 'generation-provenance.json'), 'utf8'));
  const selected = provenance.attempts.find(a => a.selected);
  if (!selected) throw new Error('No selected raw master');
  const input = path.resolve(dir, selected.saved_raw);
  if (path.dirname(input) !== dir) throw new Error('Raw master must be in the Wight directory');
  if (sha(fs.readFileSync(input)) !== selected.sha256) throw new Error('Selected raw hash differs from provenance');
  const record = await registerMaster(slug, input, provenance);
  console.log(JSON.stringify({ status: record.status, registration: record.registration, actual_registered_bounds: record.actual_registered_bounds, source_sha256: record.source_sha256, exact_mirror_verified: record.exact_mirror_verified }, null, 2));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
