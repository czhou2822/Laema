const { root, sharp, fs, path, sha, job, json, alphaBounds, registerMaster } = require('../tools/lib.cjs');
const dir = path.join(root, 'wraith');

async function capture(attempt, original) {
  const tag = String(attempt).padStart(2, '0');
  const saved = path.join(dir, `generated-raw-${tag}.png`);
  if (fs.existsSync(saved)) throw Error(`Preserve existing raw output: ${saved}`);
  fs.copyFileSync(original, saved);
  const meta = await sharp(saved).metadata();
  const pixels = await sharp(saved).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let partial = 0, zero = 0, full = 0;
  for (let i = 3; i < pixels.data.length; i += 4) {
    const a = pixels.data[i];
    if (a === 0) zero++;
    else if (a === 255) full++;
    else partial++;
  }
  const record = {
    attempt: Number(attempt), tool: 'built-in image_gen', transparent_background_requested: true,
    tool_output_path: original, saved_raw: path.basename(saved),
    generated_sha256: sha(fs.readFileSync(saved)),
    prompt_file: `generation-prompt-${tag}.txt`,
    exact_prompt: fs.readFileSync(path.join(dir, `generation-prompt-${tag}.txt`), 'utf8').trim(),
    width: meta.width, height: meta.height, has_alpha: meta.hasAlpha,
    alpha_pixels: { zero, partial, full },
    bounds_alpha8: await alphaBounds(saved, 8), bounds_alpha64: await alphaBounds(saved, 64)
  };
  const provPath = path.join(dir, 'generation-provenance.json');
  const provenance = fs.existsSync(provPath) ? JSON.parse(fs.readFileSync(provPath, 'utf8')) : {
    creature: 'Wraith', slug: 'wraith', status: 'static master awaiting human approval',
    artwork_method: 'built-in image_gen only; no CLI or API fallback',
    animation_generated: false, runtime_verified: false, attempts: []
  };
  provenance.attempts.push(record);
  json(provPath, provenance);
  console.log(JSON.stringify(record, null, 2));
}

async function register(attempt) {
  const provPath = path.join(dir, 'generation-provenance.json');
  const provenance = JSON.parse(fs.readFileSync(provPath, 'utf8'));
  const selected = provenance.attempts.find(a => a.attempt === Number(attempt));
  if (!selected) throw Error('Missing captured attempt');
  provenance.selected_raw = selected.saved_raw;
  provenance.selected_generated_sha256 = selected.generated_sha256;
  for (const a of provenance.attempts) a.selected = a.attempt === Number(attempt);
  const j = job('wraith');
  const metadataPath = path.resolve(root, j.source_metadata);
  const originalPath = path.resolve(root, j.original_def);
  const metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
  provenance.source_evidence = {
    source_id: j.source_id,
    metadata: j.source_metadata, metadata_sha256: sha(fs.readFileSync(metadataPath)),
    original_def: j.original_def, original_def_sha256: sha(fs.readFileSync(originalPath)),
    groups: metadata.groups.length,
    timeline_frames: metadata.groups.reduce((sum, g) => sum + g.frames.length, 0),
    distinct_indexed_drawings: new Set(metadata.groups.flatMap(g => g.frames.map(f => f.index_sha256))).size
  };
  provenance.reference_images = [
    ['native-idle-6x.png', 'controlling native identity and pose'],
    ['native-g02-guide.png', 'native idle pose confirmation; background and labels excluded'],
    ['../references/pikeman-rendering-master.png', 'rendering only; no costume or palette transfer']
  ].map(([file, role], index) => ({ image_index: index + 1, file, role, sha256: sha(fs.readFileSync(path.resolve(dir, file))) }));
  provenance.visual_approval = false;
  provenance.registration_override = null;
  json(provPath, provenance);
  const manifest = await registerMaster('wraith', path.join(dir, selected.saved_raw), provenance);
  await sharp(path.join(dir, 'master_source_1024x768.png'))
    .flatten({ background: '#ece8df' }).png().toFile(path.join(dir, 'master-light-review.png'));
  console.log(JSON.stringify({ registration: manifest.registration, bounds: manifest.actual_registered_bounds,
    source_sha256: manifest.source_sha256, high_res_sha256: manifest.high_res_sha256,
    mirror_sha256: manifest.mirror_sha256, source_evidence: provenance.source_evidence,
    exact_mirror_verified: manifest.exact_mirror_verified }, null, 2));
}

const [mode, attempt, original] = process.argv.slice(2);
(mode === 'capture' ? capture(attempt, original) : mode === 'register' ? register(attempt) : Promise.reject(Error('Use capture or register')))
  .catch(e => { console.error(e); process.exitCode = 1; });
