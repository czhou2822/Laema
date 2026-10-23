ACTUALLY EXECUTED: CPKMAN group12 / block11, 10 frames

Source and scale
  See ../inputs/source_contract.json. Shared native crop [150,172,296,276]
  is applied identically to all frames. Full source canvas450x400; target900x800.
  Crop output292x208; no per-frame recentering, added frames or interpolation.
  Dwell100ms is the shared provisional contract, not verified executable capture.

Methods
  nearest: exact2x nearest RGB/alpha.
  lanczos: RGB2x Lanczos after nearest valid-pixel RGB bleed; alpha exact2x.
  realesrgan: RealESRGAN_x4plus RRDBNet FP32 CPU inference on the original crop,
    nearest valid-pixel RGB bleed under transparent pixels, reflect padding10.
    Native x4 RGB result then Lanczos downsampled to target2x. Alpha exact2x.
    Original RGB retained for palette shadow pixels with0<alpha<255.
    RGB under alpha0 is zero in every deliverable. No generated alpha is used.
  Locking alpha preserves original geometry but also preserves its stair steps.
  Edge bleed helps prevent black halos; this particular edge policy has not been
  independently ablated against other fill choices.

Execution
  RealESRGAN repo commit a4abfb2979a7bbff3f69f58f58ae324608821e27
  BasicSR repo commit 8d56e3a045f9fb3e1d8872f92ee4a4f07f886b0a
  Model official release URL and SHA256 recorded in config.json.
  torch2.14.1+cpu; Python3.12.14. Total18.20s including setup inside script,
  image writes and previews; six unique inputs inferred, four exact source repeats
  reused. Individual first-six inference durations are recorded in metrics.json.
  BasicSR source forward operations unchanged; removed registry/helper imports
  and registry decorator, injected equivalent make_layer, skipped initialization
  since strict state loading replaces every parameter. No torchvision required.

Reproduce from this research directory
  python -m venv --system-site-packages runtime
  runtime/bin/pip install torch==2.14.1+cpu --index-url https://download.pytorch.org/whl/cpu
  runtime/bin/pip install numpy scipy Pillow
  git clone https://github.com/xinntao/Real-ESRGAN.git runtime/Real-ESRGAN
  git -C runtime/Real-ESRGAN checkout a4abfb2979a7bbff3f69f58f58ae324608821e27
  git clone https://github.com/XPixelGroup/BasicSR.git runtime/BasicSR
  git -C runtime/BasicSR checkout 8d56e3a045f9fb3e1d8872f92ee4a4f07f886b0a
  Download official model URL in config.json to models/RealESRGAN_x4plus.pth
  relative to this a-restoration directory and verify its SHA256.
  runtime/bin/python -u scripts/run_a_restoration.py
  The runtime inherited numpy,scipy,Pillow from the execution environment;
  requirements_freeze.txt records complete observed versions.

Verification and interpretation
  All30 output frames retain exactly the target alpha:0 changed alpha pixels.
  Repeated source pairs1/9,2/8,3/7,4/6 are pixel-identical for all methods.
  Full/crop hashes and bounding boxes are recorded in metrics.json.
  No original high-resolution ground truth exists for this test: crisp new texture
  is model inference, not proof of recovery. No gameplay runtime was run.
  Visual inspection suggests cleaner tabard/armor surfaces than Lanczos, with
  simplified interior details. Whether this looks better is an art-review question.

Review artifacts
  comparison_all_frames.png: all three methods, every frame, same2x crop.
  comparison_animated.webp: lossless synchronized comparison,10x100ms.
  comparison_animated.gif: broadly compatible quantized preview.
  Each method has crop/, full/, and a transparent preview.webp.
