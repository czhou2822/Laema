const { fs, path, sharp, sha, alphaBounds, registerMaster, json } = require('../tools/lib.cjs');

async function main() {
  const [attempt, toolOutput, mode = 'inspect'] = process.argv.slice(2);
  if (!/^\d{2}$/.test(attempt) || !toolOutput) throw new Error('Usage: node register-master.cjs NN tool-output.png [register]');
  const rawName = `generated-attempt-${attempt}.png`;
  const rawPath = path.join(__dirname, rawName);
  if (!fs.existsSync(rawPath)) fs.copyFileSync(toolOutput, rawPath);
  if (sha(fs.readFileSync(rawPath)) !== sha(fs.readFileSync(toolOutput))) throw new Error('Raw preservation hash mismatch');
  const metadata = await sharp(rawPath).metadata();
  const { data, info } = await sharp(rawPath).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const alphaHistogram = new Array(256).fill(0);
  for (let i = 3; i < data.length; i += 4) alphaHistogram[data[i]]++;
  const bounds = {};
  for (const threshold of [0, 8, 64, 200]) bounds[threshold] = await alphaBounds(rawPath, threshold);
  const record = {
    attempt: Number(attempt), tool: 'built-in image_gen', transparent_background_requested: true,
    tool_output_path: toolOutput, preserved_raw: rawName, generated_sha256: sha(fs.readFileSync(rawPath)),
    exact_prompt_file: `prompt-attempt-${attempt}.txt`, exact_prompt: fs.readFileSync(path.join(__dirname, `prompt-attempt-${attempt}.txt`), 'utf8').trimEnd(),
    prompt_file_sha256: sha(fs.readFileSync(path.join(__dirname, `prompt-attempt-${attempt}.txt`))),
    input_paths: attempt === '01' ? ['native-idle-6x.png', 'native-g02-guide.png', 'native-g12-guide.png', '../references/pikeman-rendering-master.png'] : ['generated-attempt-01.png', 'native-idle-6x.png', '../references/pikeman-rendering-master.png'],
    width: metadata.width, height: metadata.height, channels: metadata.channels, has_alpha: metadata.hasAlpha,
    alpha_counts: { transparent: alphaHistogram[0], partial: alphaHistogram.slice(1, 255).reduce((a, b) => a + b, 0), opaque: alphaHistogram[255] },
    alpha_bounds: bounds, visual_approval: false, animation_generated: false, runtime_verified: false
  };
  record.inputs = record.input_paths.map(input => ({ path: input, sha256: sha(fs.readFileSync(path.resolve(__dirname, input))) }));
  json(path.join(__dirname, `generation-attempt-${attempt}.json`), record);
  console.log(JSON.stringify({ preserved_raw: rawName, sha256: record.generated_sha256, width: metadata.width, height: metadata.height, has_alpha: metadata.hasAlpha, alpha_counts: record.alpha_counts, bounds }, null, 2));
  if (mode === 'register') {
    const manifest = await registerMaster('walking-dead', rawPath, {
      selected_attempt: Number(attempt), selected_raw: rawName, generated_sha256: record.generated_sha256,
      tool_output_path: toolOutput, generation_record: `generation-attempt-${attempt}.json`,
      exact_prompt: record.exact_prompt, exact_prompt_file: record.exact_prompt_file,
      reference_roles: 'Native CZOMBI identity/idle pose; Pikeman rendering style only',
      approval_gate: 'static master awaiting human approval; animation not begun; runtime unverified'
    });
    console.log(JSON.stringify({ registered: manifest.source, bounds: manifest.actual_registered_bounds, registration: manifest.registration, exact_mirror_verified: manifest.exact_mirror_verified }, null, 2));
    const cell = fs.readFileSync(path.join(__dirname, manifest.source));
    const enlarged = await sharp(path.join(__dirname, manifest.high_res_master)).resize(260, 580, { fit: 'inside', kernel: 'lanczos3' }).png().toBuffer();
    const enlargedMeta = await sharp(enlarged).metadata();
    await sharp({ create: { width: 1360, height: 768, channels: 4, background: '#e3e3dd' } }).composite([
      { input: cell, left: 0, top: 0 },
      { input: enlarged, left: 1070 + Math.floor((260 - enlargedMeta.width) / 2), top: 80 + Math.floor((580 - enlargedMeta.height) / 2) }
    ]).png().toFile(path.join(__dirname, 'alpha-and-scale-review.png'));
  }
}

main().catch(error => { console.error(error); process.exitCode = 1; });
