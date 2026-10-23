#!/usr/bin/env python3
"""PROPOSED ONLY: documented base Qwen + InstantX Union edge conditioning.

Separate structural-control experiment. Not the Qwen2511 reference-edit pipeline.
Accepts a precomputed/manual-corrected canny edge PNG. No identity reference input.
"""
from pathlib import Path
import argparse

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--control-image',type=Path,required=True)
    p.add_argument('--prompt',required=True)
    p.add_argument('--output',type=Path,required=True)
    args=p.parse_args()
    import torch
    from PIL import Image
    from diffusers import QwenImageControlNetPipeline,QwenImageControlNetModel
    if not torch.cuda.is_available():
        raise SystemExit('GPU execution handoff only: no CUDA GPU available. No model loaded.')
    if args.output.exists():
        raise SystemExit('Output already exists; choose a new output path.')
    control=Image.open(args.control_image).convert('RGB')
    if any(d%32 for d in control.size):
        raise SystemExit('Pad the edge canvas to multiples of32; preserve original placement.')
    net=QwenImageControlNetModel.from_pretrained(
        'InstantX/Qwen-Image-ControlNet-Union',
        revision='b13036f066d6dee7c20513e263d3d673055e9de8',torch_dtype=torch.bfloat16)
    pipe=QwenImageControlNetPipeline.from_pretrained(
        'Qwen/Qwen-Image',revision='75e0b4be04f60ec59a75f475837eced720f823b6',
        controlnet=net,torch_dtype=torch.bfloat16)
    pipe.enable_model_cpu_offload()
    out=pipe(prompt=args.prompt,negative_prompt=' ',control_image=control,
        controlnet_conditioning_scale=1.0,width=control.width,height=control.height,
        num_inference_steps=30,true_cfg_scale=4.0,
        generator=torch.Generator(device='cpu').manual_seed(42)).images[0]
    args.output.parent.mkdir(parents=True,exist_ok=True)
    out.save(args.output)

if __name__=='__main__':
    main()
