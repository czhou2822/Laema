'use strict';
(async()=>{
 if(new URL(location.href).searchParams.get('view')!=='recording'){
  const {startCharacterReview}=await import('./character-review.js?v=2026-10-24-h02-2');
  await startCharacterReview();return;
 }
 const experimentName=new URL(location.href).searchParams.get('experiment');
 if(experimentName&&experimentName!=='H01')throw new Error('This experiment has no recorded gameplay. Open the character-only view.');
 const datasetURL=new URL(experimentName==='H01'?'../2026-10-24-x1-quality-h01/outputs/replay-data.json':'outputs/replay-data.json',location.href);
 const data=await fetch(datasetURL).then(r=>{if(!r.ok)throw new Error(`Replay data: ${r.status}`);return r.json()});
 const assetBase=new URL('../',datasetURL);
 const $=id=>document.getElementById(id), canvases=[$('oldCanvas'),$('newCanvas')], contexts=canvases.map(c=>c.getContext('2d'));
 let t=-350, playing=false, previous=performance.now(), mode=2, cache=new Map(), range=data.X1_loop_ms;
 const viewports=canvases.map(c=>c.parentElement), counters=[$('oldFrameCounter'),$('newFrameCounter')], expectedPan=new WeakMap();
 let panFraction=0;
 function applyPan(){viewports.forEach(v=>{if(!v.clientWidth)return;const target=panFraction*Math.max(0,v.scrollWidth-v.clientWidth);expectedPan.set(v,target);if(Math.abs(v.scrollLeft-target)>.5)v.scrollLeft=target;});}
 function panBy(delta){const source=viewports.find(v=>v.clientWidth&&v.scrollWidth>v.clientWidth);if(!source)return;panFraction=Math.max(0,Math.min(1,panFraction+delta/(source.scrollWidth-source.clientWidth)));applyPan();}
 viewports.forEach(v=>v.addEventListener('scroll',()=>{const expected=expectedPan.get(v);if(expected!==undefined&&Math.abs(v.scrollLeft-expected)<1){expectedPan.delete(v);return;}const max=v.scrollWidth-v.clientWidth;if(max<=0)return;panFraction=v.scrollLeft/max;applyPan();},{passive:true}));
 $('views').addEventListener('wheel',e=>{if(!e.shiftKey&&Math.abs(e.deltaX)<=Math.abs(e.deltaY))return;e.preventDefault();panBy(e.deltaX||e.deltaY);},{passive:false});
 window.addEventListener('resize',applyPan);
 const imageFor=src=>{if(!cache.has(src)){const im=new Image();im.src=new URL(src,assetBase).href;cache.set(src,im);if(cache.size>256){const first=cache.keys().next().value;if(first!==src)cache.delete(first);}}return cache.get(src)};
 const at=(frames,ms)=>{let lo=0,hi=frames.length-1;while(lo<hi){const m=Math.ceil((lo+hi)/2);if(frames[m].t<=ms)lo=m;else hi=m-1;}return lo;};
 function draw(){data.runs.forEach((run,n)=>{
  const i=at(run.frames,t), frame=run.frames[i], im=imageFor(frame.src);
  const sheet=run.drawing||{suffix:n===0?'/overnight_v04/fire_x1.png':'/x1-one-pose-structural-v08.png',count:n===0?8:16,columns:8,cell:448};
  const isX1=frame.texture.endsWith(sheet.suffix);
  const drawing=isX1?Math.round(frame.region[1]/sheet.cell)*sheet.columns+Math.round(frame.region[0]/sheet.cell)+1:null;
  if(im.complete&&im.naturalWidth){contexts[n].drawImage(im,0,0);counters[n].textContent=`Captured frame ${i+1} / ${run.frames.length} · ${drawing?`X1 drawing ${drawing} / ${sheet.count}`:'Outside X1'}`;}
  else counters[n].textContent=`Loading captured frame ${i+1} / ${run.frames.length}…`;
  for(let k=1;k<=4&&i+k<run.frames.length;k++)imageFor(run.frames[i+k].src);
 });$('scrub').value=t;$('readout').textContent=`${t>=0?'+':''}${(t/1000).toFixed(3)} s from accepted X1 · ${$('speed').value==='1'?'normal speed':'¼ speed replay'} · ${playing?'playing':'paused'}`;}
 const setPlaying=value=>{playing=value;$('play').textContent=value?'Pause':'Play';previous=performance.now();draw();};
 $('play').onclick=()=>setPlaying(!playing);$('restart').onclick=()=>{t=range[0];setPlaying(true)};
 $('scrub').onpointerdown=()=>setPlaying(false);
 $('scrub').oninput=e=>{const requested=Number(e.target.value);setPlaying(false);t=requested;draw()};
 $('scrub').addEventListener('wheel',e=>{const delta=e.deltaY||e.deltaX;if(!delta)return;e.preventDefault();if(e.shiftKey||Math.abs(e.deltaX)>Math.abs(e.deltaY)){panBy(e.deltaX||e.deltaY);return;}step(delta>0?1:-1);},{passive:false});
 $('scope').onchange=()=>{range=$('scope').value==='all'?data.encounter_ms:data.X1_loop_ms;[$('scrub').min,$('scrub').max]=range;t=range[0];draw()};
 function view(n){mode=n;$('old').hidden=n===1;$('new').hidden=n===0;$('views').classList.toggle('compare',n===2);['baseline','trial','both'].forEach((id,i)=>$(id).classList.toggle('active',i===n));applyPan();draw()}
 $('trial').onclick=()=>view(1);$('baseline').onclick=()=>view(0);$('both').onclick=()=>view(2);
 $('native').onclick=()=>{const native=$('views').classList.toggle('native');$('native').textContent=`Native size: ${native?'on':'off'}`;applyPan();if(native)viewports.forEach(v=>v.scrollTop=Math.min(320,Math.max(0,v.scrollHeight-v.clientHeight)));};
 document.body.classList.add('focus');$('focus').onclick=()=>{const focused=document.body.classList.toggle('focus');$('focus').textContent=focused?'Show all controls':'Focus gameplay';applyPan();};
 function step(d){setPlaying(false);const frames=data.runs[mode===0?0:1].frames, i=at(frames,t);t=frames[Math.max(0,Math.min(frames.length-1,i+d))].t;range=[$('scrub').min,$('scrub').max].map(Number);if(t<range[0]||t>range[1]){$('scope').value='all';range=data.encounter_ms;[$('scrub').min,$('scrub').max]=range;}draw()}
 $('prev').onclick=()=>step(-1);$('next').onclick=()=>step(1);$('grip').onclick=()=>{setPlaying(false);t=data.proof_t_ms+1;draw()};
 if(data.experiment){
  const e=data.experiment;$('experimentCard').hidden=false;$('experimentQuestion').textContent=e.question;$('experimentFixed').textContent=e.fixed;$('experimentVerdict').textContent=e.verdict;
  $('experimentReference').href=new URL(e.reference,datasetURL).href;$('experimentRecord').href=new URL(e.record,datasetURL).href;
  document.title=`Laema · ${e.title}`;document.querySelector('h1').textContent=e.title;
  ['oldTitle','newTitle'].forEach((id,n)=>$(id).textContent=data.runs[n].label);
  ['oldMeta','newMeta'].forEach((id,n)=>$(id).textContent=data.runs[n].summary||'Recorded in the frozen Gym fixture');
  $('baseline').textContent=data.runs[0].label;$('trial').textContent=data.runs[1].label;$('grip').textContent='Inspect release drawing 7';
  panFraction=.5;$('native').click();
 }
 const warm=data.runs.flatMap(run=>run.frames.filter(f=>f.t>=-450&&f.t<=1300));
 $('loading').textContent='Loading X1 motion…';await Promise.all(warm.map(f=>new Promise(resolve=>{const im=imageFor(f.src);if(im.complete)resolve();else{im.onload=resolve;im.onerror=resolve;}})));$('loading').textContent='';setPlaying(true);
 function tick(now){if(playing){t+=(now-previous)*Number($('speed').value);if(t>range[1])t=range[0]+(t-range[0])%(range[1]-range[0]);}previous=now;draw();requestAnimationFrame(tick)}requestAnimationFrame(tick);
})().catch(error=>{document.getElementById('loading').textContent=`Replay could not load: ${error.message}`});
