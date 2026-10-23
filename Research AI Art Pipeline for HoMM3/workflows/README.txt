LOCAL EDITING HANDOFF -- PROPOSED, NO QWEN INFERENCE PERFORMED

This machine has18GB RAM and no CUDA GPU. Only syntax and JSON parse checks were
performed. These files must not be listed as executed experiment B results.

1. Official untouched ComfyUI2511 graph
  official/image_qwen_image_edit_2511.json is the real official template,
  downloaded byte-for-byte from workflow_templates commit
  67984637eefcd4825dcf5c134e39034785be1682. Provenance and SHA256 are in manifest.json.
  Source: https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511
  Its default example changes sofa leather to reference fur. Load it in current
  ComfyUI with the core nodes required by the embedded subgraph (version0.16.4 is
  recorded on the graph). It is an editor graph, not a ready sprite animation graph.

  Proposed manual substitutions, preserving an untouched copy of the template:
  - LoadImage41: pose_00.png, then the other five unique source poses.
  - LoadImage83: the approved appearance master; appearance_proxy.png is only a
    convenient existing project proxy, not an approved master or historical truth.
  - positive prompt151: use PROMPT in proposed_qwen2511_frame_edit.py.
  - negative prompt149: a single space, matching the documented Diffusers example.
  - Set enable_turbo_mode false (PrimitiveBoolean168), steps40 (PrimitiveInt166),
    CFG4 (PrimitiveFloat154), KSampler169 Euler/simple and fixed seed42 rather than
    randomize. No Lightning LoRA in this full-step quality trial.
  - Model161 is fp8mixed in the downloaded graph. For a full-precision trial choose
    official qwen_image_edit_2511_bf16.safetensors, matching Qwen2.5-VL7B encoder
    and qwen_image_vae.safetensors. Do not use Qwen2.1 weights/encoder/VAE here.
  - FluxKontextImageScale160 resizes the first reference. Inspect its output
    dimensions before comparing. This graph is not claimed to preserve584x416
    or608x416. For explicit dimensions use the separate proposed Diffusers script.
  - Save raw output before alpha repair/registration. Export and record the actual
    modified graph, model hashes and node versions when the local trial is run.

2. Proposed Diffusers2511 frame trial
  proposed_qwen2511_frame_edit.py uses documented QwenImageEditPlusPipeline with
  source frame + appearance reference, fixed seed42, true CFG4 and40 steps.
  Input pose584x416 is padded12px on each side to608x416. The pipeline floors
  dimensions to VAE-scale*2 multiples (normally16); passing584 directly would
  yield576px. Explicit608 output is checked before cropping back to584.
  This controls output canvas only: reference encoders internally rescale inputs
  and semantic pose/registration can still drift. Text instructions are not hard
  pose constraints. This script has no native ControlNet and outputs RGB only.
  It processes six unique RGBA pose inputs and reuses identical results for source
  repeats1/9,2/8,3/7,4/6. It never feeds previous generated frames back as references.
  Original frame order/timing remains in source_contract.json. A supplied reference
  must be reviewed by the user. Do not treat existing proxy art as accepted design.

  On a suitably provisioned CUDA machine, create a separate environment:
    pip install torch Pillow transformers accelerate
    pip install git+https://github.com/huggingface/diffusers@48cdbaef5ee3d718aaee392b44f2099ae511c4a5
    python workflows/proposed_qwen2511_frame_edit.py --reference /path/to/approved_master.png
  Choose the torch build appropriate to the GPU/CUDA runtime. No universal VRAM
  minimum was measured. The2511 visual model is20B (roughly40GB for BF16 weights
  alone) plus the7B encoder and activations; CPU offload requires substantial host
  memory. Prefer a large-memory GPU/host for full precision. Quantized workflows
  must be recorded separately; source template fp8mixed is not equivalent to BF16.

3. Separate compatible structural-control trial
  proposed_base_qwen_union.py follows the documented pairing:
    QwenImageControlNetPipeline + Qwen/Qwen-Image (20B original generation model)
    QwenImageControlNetModel + InstantX/Qwen-Image-ControlNet-Union (2B)
  It is not a2511 or2.1 plug-in. Do not connect this ControlNet to either model
  based solely on a similar name. This example takes an edge control and text;
  no approved character-reference conditioning is claimed. It is an auxiliary
  edge-adherence experiment, not a complete identity-consistent B pipeline.
  Primary source: https://huggingface.co/InstantX/Qwen-Image-ControlNet-Union
  Generate canny with cv2.Canny or use a manually corrected edge PNG; retain the
  fixed padded pose canvas. The card recommends conditioning0.8..1.0; start1.0,
  steps30,true CFG4,seed42. Do not trust a human pose detector on tiny armor,
  hands, spear and nonhuman creatures without inspecting/correcting its output.
  Example invocation after preparing the edge PNG:
    python workflows/proposed_base_qwen_union.py --control-image /path/edges.png --prompt 'Detailed Castle pikeman, original pose and camera, neutral gray background' --output /new/path/result.png

4. Review requirements after a real run
  Compare raw and corrected derivatives separately. Check frame count/order,
  output dimensions, original-relative anchors and weapon endpoints, alpha,
  repeated-frame equality and all frames played at the shared timing. A forced
  source mask can preserve geometry while hiding bad generated anatomy; report it.
  Native RGBA Qwen2.1 is a separate research alternative with different architecture
  and a Research License; do not silently replace2511 with it. All2511 and the
  original InstantX model cards used here identify Apache2.0. Retain downloaded
  notices and check any extra checkpoint/LoRA license before production use.
