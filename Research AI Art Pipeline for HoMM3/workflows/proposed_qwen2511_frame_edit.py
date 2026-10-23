#!/usr/bin/env python3
"""PROPOSED ONLY. Syntax checked; never loaded or ran Qwen in this environment.

Pinned documented QwenImageEditPlusPipeline reference editing, six unique source
poses plus exact-repeat reuse. RGB output is not a production transparent asset.
"""
from pathlib import Path
import argparse, hashlib, json, time

ROOT=Path(__file__).resolve().parents[1]
MODEL='Qwen/Qwen-Image-Edit-2511'
REVISION='6f3ccc0b56e431dc6a0c2b2039706d7d26f22cb9'
PROMPT=(
    'Restore the Castle pikeman in image 1 using only the character design, colors, '
    'materials, and equipment details shown in image 2. Image 1 is the authority '
    'for the pose and composition. Preserve its camera, silhouette, body '
    'proportions, limb positions, spear shaft angle, spear endpoints, foot contact '
    'positions, and placement in the canvas. Keep the neutral gray background. '
    'Create exactly one character. Add restrained readable surface detail without '
    'changing the action or inventing equipment.'
)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--reference',type=Path,default=ROOT/'inputs/appearance_proxy.png')
    p.add_argument('--output',type=Path,default=ROOT/'workflows/proposed_b_outputs')
    p.add_argument('--seed',type=int,default=42)
    args=p.parse_args()
    import torch
    from PIL import Image
    from diffusers import QwenImageEditPlusPipeline
    if not torch.cuda.is_available():
        raise SystemExit('GPU execution handoff only: no CUDA GPU available. No model loaded.')
    if args.output.exists():
        raise SystemExit('Output already exists; choose a new --output directory.')
    args.output.mkdir(parents=True)
    contract=json.loads((ROOT/'inputs/source_contract.json').read_text())
    def composite(im):
        im=im.convert('RGBA')
        return Image.alpha_composite(Image.new('RGBA',im.size,(128,128,128,255)),im).convert('RGB')
    reference=composite(Image.open(args.reference))
    manifest={
        'status':'starting','model':MODEL,'revision':REVISION,
        'seed':args.seed,'true_cfg_scale':4.0,'guidance_scale':1.0,'steps':40,
        'prompt':PROMPT,'negative_prompt':' ','reference':str(args.reference),
        'reference_status':'Existing project appearance proxy unless replaced with an approved master',
        'input_crop_size':[584,416],'model_canvas':[608,416],
        'padding':[12,0,12,0],'padding_color':[128,128,128],
        'timing_status':contract['timing_status'],
        'alpha_status':'RGB only; no transparency repair or forced source mask applied',
        'frames':[],
    }
    log=args.output/'run_manifest.json'
    log.write_text(json.dumps(manifest,indent=2))
    try:
        pipe=QwenImageEditPlusPipeline.from_pretrained(MODEL,revision=REVISION,torch_dtype=torch.bfloat16)
        pipe.enable_model_cpu_offload()
        cache={}
        for i in range(contract['count']):
            pose=Image.open(ROOT/'inputs'/f'pose_{i:02d}.png').convert('RGBA')
            if pose.size!=(584,416):
                raise ValueError(f'Unexpected source crop dimensions: {pose.size}')
            key=hashlib.sha256(pose.tobytes()).hexdigest()
            padded=Image.new('RGB',(608,416),(128,128,128))
            padded.paste(composite(pose),(12,0))
            tick=time.perf_counter()
            reused=key in cache
            if reused:
                raw=cache[key].copy()
            else:
                raw=pipe(
                    image=[padded,reference],prompt=PROMPT,
                    negative_prompt=' ',true_cfg_scale=4.0,
                    guidance_scale=1.0,num_inference_steps=40,
                    width=608,height=416,num_images_per_prompt=1,
                    generator=torch.Generator(device='cpu').manual_seed(args.seed),
                ).images[0]
                if raw.size!=(608,416):
                    raise ValueError(f'Unexpected pipeline output dimensions: {raw.size}')
                cache[key]=raw.copy()
            raw.save(args.output/f'raw_padded_{i:02d}.png')
            raw.crop((12,0,596,416)).save(args.output/f'raw_crop_{i:02d}.png')
            manifest['frames'].append({'index':i,'source_sha256_rgba':key,
                'reused_exact_input':reused,'seconds':time.perf_counter()-tick})
            log.write_text(json.dumps(manifest,indent=2))
        manifest['status']='completed';manifest['unique_inferences']=len(cache)
    except Exception as exc:
        manifest['status']='failed';manifest['error']=str(exc)
        raise
    finally:
        log.write_text(json.dumps(manifest,indent=2))

if __name__=='__main__':
    main()
