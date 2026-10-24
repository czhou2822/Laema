'use strict';
(async()=>{
 const data=await fetch('outputs/replay-data.json').then(r=>r.json());
 const $=id=>document.getElementById(id), canvases=[$('oldCanvas'),$('newCanvas')], contexts=canvases.map(c=>c.getContext('2d'));
 let t=-350, playing=false, previous=performance.now(), mode=1, cache=new Map(), range=data.X1_loop_ms;
 const imageFor=src=>{if(!cache.has(src)){const im=new Image();im.src=src;cache.set(src,im);if(cache.size>160){const first=cache.keys().next().value;if(first!==src)cache.delete(first);}}return cache.get(src)};
 const at=(frames,ms)=>{let lo=0,hi=frames.length-1;while(lo<hi){const m=Math.ceil((lo+hi)/2);if(frames[m].t<=ms)lo=m;else hi=m-1;}return lo;};
 function draw(){data.runs.forEach((run,n)=>{const i=at(run.frames,t), frame=run.frames[i], im=imageFor(frame.src);if(im.complete&&im.naturalWidth)contexts[n].drawImage(im,0,0);for(let k=1;k<=4&&i+k<run.frames.length;k++)imageFor(run.frames[i+k].src);});$('scrub').value=t;$('readout').textContent=`${t>=0?'+':''}${(t/1000).toFixed(3)} s from accepted X1 · ${$('speed').value==='1'?'normal speed':'¼ speed replay'} · ${playing?'playing':'paused'}`;}
 const setPlaying=value=>{playing=value;$('play').textContent=value?'Pause':'Play';previous=performance.now();draw();};
 $('play').onclick=()=>setPlaying(!playing);$('restart').onclick=()=>{t=range[0];setPlaying(true)};
 $('scrub').oninput=e=>{setPlaying(false);t=Number(e.target.value);draw()};
 $('scope').onchange=()=>{range=$('scope').value==='all'?data.encounter_ms:data.X1_loop_ms;[$('scrub').min,$('scrub').max]=range;t=range[0];draw()};
 function view(n){mode=n;$('old').hidden=n===1;$('new').hidden=n===0;$('views').classList.toggle('compare',n===2);['baseline','trial','both'].forEach((id,i)=>$(id).classList.toggle('active',i===n));draw()}
 $('trial').onclick=()=>view(1);$('baseline').onclick=()=>view(0);$('both').onclick=()=>view(2);
 $('native').onclick=()=>{const native=$('views').classList.toggle('native');$('native').textContent=`Native size: ${native?'on':'off'}`};
 document.body.classList.add('focus');$('focus').onclick=()=>{const focused=document.body.classList.toggle('focus');$('focus').textContent=focused?'Show all controls':'Focus gameplay';};
 function step(d){setPlaying(false);const frames=data.runs[mode===0?0:1].frames, i=at(frames,t);t=frames[Math.max(0,Math.min(frames.length-1,i+d))].t;range=[$('scrub').min,$('scrub').max].map(Number);if(t<range[0]||t>range[1]){$('scope').value='all';range=data.encounter_ms;[$('scrub').min,$('scrub').max]=range;}draw()}
 $('prev').onclick=()=>step(-1);$('next').onclick=()=>step(1);$('grip').onclick=()=>{setPlaying(false);t=data.proof_t_ms+1;draw()};
 const warm=data.runs.flatMap(run=>run.frames.filter(f=>f.t>=-450&&f.t<=1300));
 $('loading').textContent='Loading X1 motion…';await Promise.all(warm.map(f=>new Promise(resolve=>{const im=imageFor(f.src);if(im.complete)resolve();else{im.onload=resolve;im.onerror=resolve;}})));$('loading').textContent='';setPlaying(true);
 function tick(now){if(playing){t+=(now-previous)*Number($('speed').value);if(t>range[1])t=range[0]+(t-range[0])%(range[1]-range[0]);}previous=now;draw();requestAnimationFrame(tick)}requestAnimationFrame(tick);
})().catch(error=>{document.getElementById('loading').textContent=`Replay could not load: ${error.message}`});
