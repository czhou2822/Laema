/* Structural still-pose inspection; blink is outside the gameplay clock. */
(()=>{
  const ids=['pose-game','pose-source','pose-proof'],labels=['Current game','v05 source','v08 structural proof'];
  let blinking=false,showSource=false,timer;
  function at(c){let k=0;c.times.forEach((time,i)=>{if(time<=t+1e-8)k=i;});return k;}
  function stopBlink(){if(timer)clearInterval(timer);timer=undefined;blinking=false;showSource=false;document.getElementById('blink').setAttribute('aria-pressed','false');document.getElementById('proposal-zoom').src='outputs/v08-arm-grip-4x.png';document.getElementById('proposal-caption').textContent='v08 · changed arm/wrist pose · 4× native pixels';}
  function jump(lane,k){stopBlink();playing=false;gap=0;t=data.clips[lane].times[k];draw();}
  ids.forEach((id,lane)=>{const control=document.getElementById(id);data.clips[lane].times.forEach((time,i)=>{const o=document.createElement('option');o.value=String(i);o.textContent='#'+(i+1)+' · '+time.toFixed(3)+'s'+(lane===2&&i===6?' · structural proof':'');control.appendChild(o);});control.onchange=e=>jump(lane,Number(e.target.value));});
  document.getElementById('pin-grip').onclick=()=>jump(2,6);
  const selectBase=selected;selected=function(){const c=selectBase();return blinking&&showSource?[c[0],c[1],{...c[1],label:'3 · v05 / blink reference'}]:c;};
  document.getElementById('blink').onclick=()=>{if(blinking){stopBlink();draw();return;}playing=false;gap=0;t=.158;blinking=true;showSource=false;document.getElementById('blink').setAttribute('aria-pressed','true');timer=setInterval(()=>{showSource=!showSource;document.getElementById('proposal-zoom').src=showSource?'outputs/v05-arm-grip-4x.png':'outputs/v08-arm-grip-4x.png';document.getElementById('proposal-caption').textContent=showSource?'v05 · blink reference / unchanged wrist':'v08 · structural proposal / changed silhouette';draw();},650);draw();};
  document.getElementById('play').addEventListener('click',()=>{stopBlink();draw();});
  const base=draw;draw=function(){base();if(!ready)return;const keys=data.clips.map(at);keys.forEach((k,i)=>document.getElementById(ids[i]).value=String(k));document.getElementById('pose-jump-status').textContent=(blinking?'Inspection blink / key7 held':playing?'Playing partial context':'Paused')+' · '+keys.map((k,i)=>labels[i]+' #'+(k+1)).join(' / ');ctx.font='12px Segoe UI';['User preferred overall','Source wrist geometry',blinking&&showSource?'Blink reference / v05':keys[2]===6?'Changed silhouette; not approved':'UNCHANGED v05 key; not fixed'].forEach((note,i)=>{ctx.fillStyle='#c9bea3';ctx.fillText(note,i*320+13,73);});};draw();
})();
