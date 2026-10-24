/* A one-key grip proof, with source/proof labels kept explicit. */
(()=>{
  const ids=['pose-game','pose-source','pose-proof'],labels=['Current game','v05 source','v06 grip proof'];
  function keyAt(c){let k=0;c.times.forEach((time,i)=>{if(time<=t+1e-8)k=i;});return k;}
  function jump(lane,k){playing=false;gap=0;t=data.clips[lane].times[k];draw();}
  ids.forEach((id,lane)=>{
    const control=document.getElementById(id);
    data.clips[lane].times.forEach((time,i)=>{const o=document.createElement('option');o.value=String(i);o.textContent='#'+(i+1)+' · '+time.toFixed(3)+'s'+(lane===2&&i===6?' · grip proof':'');control.appendChild(o);});
    control.onchange=e=>jump(lane,Number(e.target.value));
  });
  document.getElementById('pin-grip').onclick=()=>jump(2,6);
  const base=draw;draw=function(){base();if(!ready)return;const keys=data.clips.map(keyAt);keys.forEach((k,i)=>document.getElementById(ids[i]).value=String(k));document.getElementById('pose-jump-status').textContent=(playing?'Playing context':'Paused')+' · '+keys.map((k,i)=>labels[i]+' #'+(k+1)).join(' / ');ctx.font='12px Segoe UI';['User preferred overall','Wrist/hilt still rejected',keys[2]===6?'ONE repaired key; not approved':'UNCHANGED v05 key; not repaired'].forEach((note,i)=>{ctx.fillStyle=i===2&&keys[2]===6?'#aaccc6':'#d3b6a0';ctx.fillText(note,i*320+13,73);});};draw();
})();
