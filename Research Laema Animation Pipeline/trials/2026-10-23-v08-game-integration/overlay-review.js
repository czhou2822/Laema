// View-only aligned overlays. Source bitmaps, timing and notes are never moved.
export function createOverlayComparison({versions,time,frameAt,paint,pause,draw,beginNote,status}){
 const byId=Object.fromEntries(versions.map(v=>[v.id,v])),layers=new Map(),buffers=new Map();
 let dragSource=null,suppressUntil=0;
 const css=document.createElement('style');css.textContent=`.overlay-drag{float:right;font-size:11px;padding:3px 6px;cursor:grab}.cr-card.overlay-drop{outline:2px solid #9ce8c2;outline-offset:-3px}.overlay-controls{padding:4px 10px 7px;font-size:12px;color:#bcd6e8}.overlay-controls[hidden],#overlayPicker[hidden]{display:none}.overlay-controls input{width:100%;accent-color:#9adcc6}.overlay-controls button{font-size:11px;padding:3px 6px;margin-right:5px}#overlayPicker{margin:5px 0;padding:8px;background:#1d3040;border-radius:6px;font-size:13px}#overlayPicker button,#overlayPicker select{font-size:12px;padding:5px 7px}`;document.head.append(css);
 const picker=document.createElement('div');picker.id='overlayPicker';picker.hidden=true;
 const pickerText=document.createElement('span'),target=document.createElement('select');target.setAttribute('aria-label','Overlay destination');const apply=document.createElement('button'),cancel=document.createElement('button');apply.textContent='Overlay';cancel.textContent='Cancel';let pickerSource=null;picker.append(pickerText,target,apply,cancel);document.querySelector('.cr-controls').after(picker);
 function contextFor(base){const layer=layers.get(base);if(!layer)return null;return {base_version_id:base,base_sprite_sha256:byId[base].sprite_sha256,overlay_version_id:layer.source,overlay_sprite_sha256:byId[layer.source].sprite_sha256,overlay_opacity:layer.opacity,action_time_heat0_s:time()}}
 function setOverlay(source,base,opacity=.5){if(!byId[source]||!byId[base]||source===base){status('Drag onto a different version to compare.');return}layers.set(base,{source,opacity});const row=document.getElementById(`overlay-${base}`);row.hidden=false;row.querySelector('input').value=opacity*100;document.querySelector(`#card-${base} [data-note]`).textContent='Note base';picker.hidden=true;pause();draw();status(`${byId[source].label} over ${byId[base].label}, aligned at the foot anchor. Adjust opacity or clear the overlay.`)}
 apply.onclick=()=>setOverlay(pickerSource,target.value);cancel.onclick=()=>{picker.hidden=true};
 for(const v of versions){
  const card=document.getElementById(`card-${v.id}`),canvas=document.getElementById(`canvas-${v.id}`),handle=document.createElement('button');handle.type='button';handle.className='overlay-drag';handle.textContent='⠿ Drag';handle.setAttribute('aria-label',`Drag ${v.label} as overlay`);handle.title='Drag this version onto another, or click to choose a destination';handle.draggable=true;handle.dataset.overlaySource=v.id;card.querySelector('h2').append(handle);canvas.draggable=true;canvas.title='Drag to overlay another version; click to annotate the base version';
  const start=e=>{pause();dragSource=v.id;suppressUntil=performance.now()+500;e.dataTransfer.setData('application/x-laema-version',v.id);e.dataTransfer.setData('text/plain',v.label);e.dataTransfer.effectAllowed='copy'};
  const end=()=>{suppressUntil=performance.now()+300;dragSource=null;versions.forEach(other=>document.getElementById(`card-${other.id}`).classList.remove('overlay-drop'))};
  for(const el of [handle,canvas]){el.addEventListener('dragstart',start);el.addEventListener('dragend',end)}
  handle.onpointerdown=pause;handle.onclick=()=>{if(performance.now()<suppressUntil)return;pickerSource=v.id;pickerText.textContent=`Overlay ${v.label} onto `;target.replaceChildren(...versions.filter(other=>other.id!==v.id).map(other=>new Option(other.label,other.id)));picker.hidden=false};
  card.addEventListener('dragover',e=>{if(!dragSource&&!Array.from(e.dataTransfer.types).includes('application/x-laema-version'))return;e.preventDefault();e.dataTransfer.dropEffect='copy';if(dragSource!==v.id)card.classList.add('overlay-drop')});
  card.addEventListener('dragleave',e=>{if(!card.contains(e.relatedTarget))card.classList.remove('overlay-drop')});
  card.addEventListener('drop',e=>{e.preventDefault();card.classList.remove('overlay-drop');const source=e.dataTransfer.getData('application/x-laema-version')||dragSource;suppressUntil=performance.now()+300;setOverlay(source,v.id)});
  const row=document.createElement('div');row.id=`overlay-${v.id}`;row.className='overlay-controls';row.hidden=true;
  const label=document.createElement('div'),slider=document.createElement('input'),clear=document.createElement('button'),note=document.createElement('button');label.dataset.overlayLabel='';slider.type='range';slider.min='0';slider.max='100';slider.value='50';slider.setAttribute('aria-label',`Overlay opacity on ${v.label}`);clear.textContent='Clear overlay';note.textContent='Note overlay';
  slider.oninput=e=>{const layer=layers.get(v.id);if(!layer)return;layer.opacity=Number(e.target.value)/100;draw()};
  clear.onclick=()=>{layers.delete(v.id);row.hidden=true;document.querySelector(`#card-${v.id} [data-note]`).textContent='Note this frame';draw()};
  note.onpointerdown=pause;note.onclick=()=>{const layer=layers.get(v.id);if(layer)beginNote(byId[layer.source],null,contextFor(v.id))};
  row.append(label,slider,clear,note);card.querySelector('.spriteViewport').after(row);
 }
 return {
  sourceFor(base){return layers.has(base)?byId[layers.get(base).source]:null},
  contextFor,
  restore(comparison){if(!comparison)return;const base=byId[comparison.base_version_id],source=byId[comparison.overlay_version_id];if(base?.sprite_sha256===comparison.base_sprite_sha256&&source?.sprite_sha256===comparison.overlay_sprite_sha256)setOverlay(source.id,base.id,comparison.overlay_opacity)},
  annotationVersion(base,draft){const layer=layers.get(base);return layer&&draft?.version_id===layer.source?byId[layer.source]:byId[base]},
  suppressClick(){return performance.now()<suppressUntil},
  render(ctx,base){
   const layer=layers.get(base.id);if(!layer){paint(ctx,base,1,'source-over');return}
   const overlay=byId[layer.source];let buffer=buffers.get(base.id);if(!buffer){buffer=document.createElement('canvas');buffers.set(base.id,buffer)}
   if(buffer.width!==ctx.canvas.width||buffer.height!==ctx.canvas.height){buffer.width=ctx.canvas.width;buffer.height=ctx.canvas.height}
   const mix=buffer.getContext('2d');mix.setTransform(1,0,0,1,0,0);mix.clearRect(0,0,buffer.width,buffer.height);
   // Weighted premultiplied blend: identical artwork stays identical, rather
   // than acquiring a false double edge from source-over transparency.
   paint(mix,base,1-layer.opacity,'source-over');paint(mix,overlay,layer.opacity,'lighter');ctx.drawImage(buffer,0,0);
   document.querySelector(`#overlay-${base.id} [data-overlay-label]`).textContent=`Overlay: ${overlay.label} · frame ${frameAt(overlay,time())+1}/${overlay.times.length} · ${Math.round(layer.opacity*100)}%`;
  }
 };
}
