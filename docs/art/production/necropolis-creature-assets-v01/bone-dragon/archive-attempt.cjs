const { fs, path, root, sharp, sha, json, alphaBounds } = require('../tools/lib.cjs');

(async () => {
  const [number, generatedPath] = process.argv.slice(2);
  if (!/^\d{2}$/.test(number) || !generatedPath) throw Error('Usage: archive-attempt.cjs NN generated-path');
  const dir = path.join(root, 'bone-dragon');
  const rawName = `raw-${number}.png`;
  const rawPath = path.join(dir, rawName);
  if (fs.existsSync(rawPath)) throw Error('Attempt already archived');
  fs.copyFileSync(generatedPath, rawPath, fs.constants.COPYFILE_EXCL);
  const promptFile = `prompt-${number}.txt`;
  const prompt = fs.readFileSync(path.join(dir, promptFile), 'utf8').trimEnd();
  const inputs = {
    '01': ['native-idle-6x.png', '../references/pikeman-rendering-master.png'],
    '02': ['raw-01.png', 'native-idle-6x.png'],
    '03': ['native-idle-6x.png', 'raw-01.png'],
    '04': ['raw-01.png']
  }[number];
  if (!inputs) throw Error('No exact input list recorded for this attempt');
  const metadata = await sharp(rawPath).metadata();
  const bounds = await alphaBounds(rawPath);
  const { data, info } = await sharp(rawPath).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  let transparent = 0, partial = 0, opaque = 0, borderNonzero = 0, redYellowSaturated = 0;
  for (let y = 0; y < info.height; y++) for (let x = 0; x < info.width; x++) {
    const n = (y * info.width + x) * 4;
    const [r, g, b, a] = data.subarray(n, n + 4);
    if (!a) transparent++; else if (a === 255) opaque++; else partial++;
    if (a && (x === 0 || y === 0 || x === info.width - 1 || y === info.height - 1)) borderNonzero++;
    if (a > 8 && ((r > 180 && g < 100 && b < 80) || (r > 180 && g > 160 && b < 60))) redYellowSaturated++;
  }
  const exactArguments = { prompt, referenced_image_paths: inputs.map(file => path.resolve(dir, file).replaceAll('\\', '/')), transparent_background: true };
  json(path.join(dir, `tool-call-${number}.json`), {
    tool: 'functions.exec -> tools.image_gen__imagegen', mode: 'built-in imagegen',
    args: exactArguments, prompt_file: promptFile, prompt_file_sha256: sha(fs.readFileSync(path.join(dir, promptFile))),
    prompt_argument_utf8_sha256: sha(Buffer.from(prompt)),
    inputs: inputs.map(file => ({ file, sha256: sha(fs.readFileSync(path.resolve(dir, file))) })),
    returned_generated_path: generatedPath, archived_raw: rawName,
    returned_raw_sha256: sha(fs.readFileSync(generatedPath)), archived_raw_sha256: sha(fs.readFileSync(rawPath)),
    metadata: { width: metadata.width, height: metadata.height, channels: metadata.channels, hasAlpha: metadata.hasAlpha },
    alpha_bounds_threshold8: bounds,
    alpha_statistics: { transparent, partial, opaque, borderNonzero, redYellowSaturated },
    raw_preserved_byte_identical: sha(fs.readFileSync(generatedPath)) === sha(fs.readFileSync(rawPath)),
    approval: false, animation_generated: false
  });
  for (const [name, background] of [['dark', '#1b2936'], ['light', '#e7e1d5']]) {
    await sharp(rawPath).flatten({ background }).png().toFile(path.join(dir, `raw-${number}-on-${name}.png`));
  }
  console.log(JSON.stringify({ raw: rawName, dimensions: [metadata.width, metadata.height], bounds, alpha_statistics: { transparent, partial, opaque, borderNonzero, redYellowSaturated }, sha256: sha(fs.readFileSync(rawPath)) }, null, 2));
})().catch(error => { console.error(error); process.exitCode = 1; });
