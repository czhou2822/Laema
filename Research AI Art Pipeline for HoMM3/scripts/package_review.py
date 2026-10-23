from pathlib import Path
import hashlib,json,zipfile

r=Path(__file__).resolve().parents[1]
selected=set()
rootfiles=['README.txt','report.html','report.pdf','comparison_all_methods.png','comparison_keyframes.png','comparison_animated.webp','comparison_animated.gif','silhouette_overlay.webp','silhouette_overlay_frame05.png','generation_manifest.json','packaging.json','experiment_metrics.json','preview_checks.json','report_checks.json','project_render_audit.md','runtime-sheet-audit.json']
for n in rootfiles:selected.add(r/n)
for folder in ['inputs','a-restoration','b-edit','c-strip','visual_audit','workflows','scripts']:
 for p in (r/folder).rglob('*'):
  if not p.is_file():continue
  rel=p.relative_to(r).as_posix()
  if '/models/' in rel or '__pycache__' in rel or rel.endswith('report_client.js'):continue
  if rel.startswith('c-strip/raw/cell_'):continue
  if rel.startswith('workflows/official/') and p.name not in ['image_qwen_image_edit_2511.json','workflow_templates_LICENSE']:continue
  selected.add(p)
for n in ['README.md','candidates.json','run_capture.sh','make_comparisons.py','xorg.conf','normalized-capture.log','project/research_capture.gd','normalized/capture-report.json','normalized/engine-comparison-detail.png','normalized/engine-comparison-fullthrust.png','normalized/engine-comparison-fiveway.png','normalized/engine-comparison-animated.webp','normalized/engine-comparison-animated.gif']:
 p=r/'gameplay-preview'/n
 if p.exists():selected.add(p)
index={'files':[{'path':p.relative_to(r).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(selected)]}
(r/'bundle_manifest.json').write_text(json.dumps(index,indent=2));selected.add(r/'bundle_manifest.json')
output=r/'homm3-pipeline-review.zip'
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(selected):z.write(p,'homm3-research/'+p.relative_to(r).as_posix())
with zipfile.ZipFile(output) as z:
 bad=z.testzip()
 if bad:raise RuntimeError(f'CRC failure: {bad}')
 print(json.dumps({'zip':str(output),'files':len(z.infolist()),'bytes':output.stat().st_size,'crc_check':'passed'}))
