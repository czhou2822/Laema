/* Exact drawing-key jumps and explicit version-bound user feedback. */
(()=>{
  const labels=['Current game','v03 reference','v05 trial'];
  const ids=['pose-game','pose-v03','pose-v05'];
  function indexAt(clip){let k=0;for(let i=0;i<clip.times.length;i++)if(clip.times[i]<=t+1e-8)k=i;return k;}
  function jump(lane,key){playing=false;gap=0;t=data.clips[lane].times[key];draw();}
  ids.forEach((id,lane)=>{
    const control=document.getElementById(id);
    data.clips[lane].times.forEach((time,i)=>{
      const option=document.createElement('option');option.value=String(i);
      option.textContent='#'+(i+1)+' · '+time.toFixed(3)+'s'+(lane===2&&i>=1&&i<=3?' · held chamber':'');control.appendChild(option);
    });
    control.onchange=e=>jump(lane,Number(e.target.value));
  });
  document.getElementById('pin-v03-2').onclick=()=>jump(1,1);
  document.getElementById('pin-v03-3').onclick=()=>jump(1,2);
  document.getElementById('pin-v05-5').onclick=()=>jump(2,4);
  const drawBase=draw;
  draw=function(){
    drawBase();if(!ready)return;
    const keys=data.clips.map(indexAt);keys.forEach((key,i)=>document.getElementById(ids[i]).value=String(key));
    document.getElementById('pose-jump-status').textContent=(playing?'Playing':'Paused')+' · '+keys.map((key,i)=>labels[i]+' #'+(key+1)).join(' / ');
    const notes=['User: preferred overall',keys[1]===1?'User: relatively better':keys[1]===2?'User: arm/sword rejected':'v03 reference; not approved',keys[2]>=1&&keys[2]<=3?'Exact v03 #2 chamber reuse':keys[2]>=4&&keys[2]<=6?'New release drawing':'Retained v04; not approved'];
    ctx.font='12px Segoe UI';notes.forEach((note,i)=>{ctx.fillStyle=i===1&&keys[1]===2?'#eda49c':'#c7bb97';ctx.fillText(note,i*320+13,73);});
  };
  draw();
})();
