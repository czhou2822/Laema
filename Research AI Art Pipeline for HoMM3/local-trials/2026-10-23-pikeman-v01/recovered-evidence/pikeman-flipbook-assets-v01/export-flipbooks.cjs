const fs=require('fs'),path=require('path'),crypto=require('crypto');
const sharp=require('C:/Users/zhouc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const out=__dirname,spec=JSON.parse(fs.readFileSync(path.join(out,'export-spec.json'),'utf8'));
const transparent={r:0,g:0,b:0,alpha:0};
function alphaStats(data,w,h){let x0=w,y0=h,x1=-1,y1=-1,border=0,solid=0,partial=0;
for(let y=0;y<h;y++)for(let x=0;x<w;x++){const a=data[(y*w+x)*4+3];if(a>=128){x0=Math.min(x0,x);y0=Math.min(y0,y);x1=Math.max(x1,x);y1=Math.max(y1,y);}if(a===255)solid++;else if(a>0)partial++;if((x===0||y===0||x===w-1||y===h-1)&&a)border++;}
return{bounds:[x0,y0,x1+1,y1+1],solid,partial,border};}
function label(text,w,h,extra=''){return Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="'+w+'" height="'+h+'"><text x="16" y="26" font-family="Arial" font-size="17" fill="#e0e8ee">'+text+'</text>'+extra+'</svg>');}
async function main(){
fs.copyFileSync('C:/Users/zhouc/.codex/generated_images/01a07f41-7159-70f1-ac7d-e6217941c130/exec-6826face-e093-4537-9b90-0dd120635925.png',path.join(out,'thrust-repaired-source.png'));
const outputs=[],clips=[],contactParts=[];let row=0;
for(const clip of spec.clips){const unique=[],records=[];
for(let ri=0;ri<clip.regions.length;ri++){
const r=clip.regions[ri],file=path.join(out,r.file||clip.name+'-generated-source.png');
const [x,y,w,h]=r.rect;let original=await sharp(file).extract({left:x,top:y,width:w,height:h}).png().toBuffer();
let expandedTop=0;
if(r.tip_rect){const[tx,ty,tw,th]=r.tip_rect,tip=await sharp(file).extract({left:tx,top:ty,width:tw,height:th}).png().toBuffer();expandedTop=y-ty;
original=await sharp({create:{width:w,height:h+expandedTop,channels:4,background:transparent}}).composite([{input:original,left:0,top:expandedTop},{input:tip,left:tx-x,top:0}]).png().toBuffer();}
const raw=await sharp(original).ensureAlpha().raw().toBuffer({resolveWithObject:true});
for(let i=0;i<raw.data.length;i+=4){const a=raw.data[i+3];if(a<=2){raw.data.fill(0,i,i+4);}else if(a>=240)raw.data[i+3]=255;}
const scale=r.scale||clip.scale,nw=Math.round(raw.info.width*scale),nh=Math.round(raw.info.height*scale);
const resized=await sharp(raw.data,{raw:raw.info}).resize(nw,nh).png().toBuffer();
const ax=(r.anchor[0]-x)*scale,ay=(r.anchor[1]-y+expandedTop)*scale;
const left=Math.round(spec.anchor[0]-ax+(r.offset?.[0]||0)),top=Math.round(spec.anchor[1]-ay+(r.offset?.[1]||0));
if(left<0||top<0||left+nw>768||top+nh>512)throw Error('Frame bounds '+clip.name+ri);
const frame=await sharp({create:{width:768,height:512,channels:4,background:transparent}}).composite([{input:resized,left,top}]).png().toBuffer();
unique.push(frame);records.push({region:ri,source:path.basename(file),source_rect:r.rect,scale,placement:[left,top],registration_anchor:r.anchor,offset:r.offset||[0,0]});
}
const frames=clip.map.map(i=>unique[i]);const clipDir=path.join(out,clip.name);fs.mkdirSync(clipDir,{recursive:true});const stats=[];
for(let i=0;i<frames.length;i++){
const name=clip.name+'_right_'+String(i).padStart(2,'0')+'.png',p=path.join(clipDir,name);fs.writeFileSync(p,frames[i]);await sharp(frames[i]).flop().png().toFile(path.join(clipDir,clip.name+'_left_'+String(i).padStart(2,'0')+'.png'));
const raw=await sharp(frames[i]).ensureAlpha().raw().toBuffer({resolveWithObject:true});const st=alphaStats(raw.data,768,512);if(st.border||!st.solid)throw Error('Alpha failure '+name);stats.push({...st,frame:i,sha256:crypto.createHash('sha256').update(frames[i]).digest('hex')});
}
for(const facing of ['right','left']){const inputs=await Promise.all(frames.map(async(b,i)=>({input:facing==='right'?b:await sharp(b).flop().png().toBuffer(),left:(i%4)*768,top:Math.floor(i/4)*512})));
await sharp({create:{width:3072,height:Math.ceil(frames.length/4)*512,channels:4,background:transparent}}).composite(inputs).png().toFile(path.join(out,clip.name+'_'+facing+'_sheet.png'));
}
const gifFrames=[];
for(let i=0;i<frames.length;i++){
const crop=await sharp(frames[i]).extract({left:144,top:160,width:480,height:320}).flatten({background:'#253340'}).png().toBuffer();
const txt=label(clip.name.toUpperCase()+' / '+String(i+1).padStart(2,'0')+' of '+frames.length,480,320,'<line x1="0" y1="288" x2="480" y2="288" stroke="#5a6c76" stroke-width="1"/><text x="16" y="311" font-family="Arial" font-size="13" fill="#b8c9d4">180px standing body / review playback only</text>');
gifFrames.push(await sharp(crop).composite([{input:txt}]).raw().toBuffer());
}
const gifData=Buffer.concat(gifFrames),delays=frames.map(()=>Math.round(100/clip.fps)*10);if(!clip.loop)delays[delays.length-1]=700;
await sharp(gifData,{raw:{width:480,height:320*frames.length,channels:4,pageHeight:320}}).gif({loop:0,delay:delays,effort:7,interFrameMaxError:0}).toFile(path.join(out,clip.name+'-preview.gif'));
for(let i=0;i<frames.length;i++){const small=await sharp(frames[i]).extract({left:160,top:180,width:448,height:290}).resize(224,145).flatten({background:row%2?'#34414b':'#283741'}).png().toBuffer();contactParts.push({input:small,left:i*224,top:row*180+30});contactParts.push({input:label(clip.name.toUpperCase()+' '+(i+1),224,30),left:i*224,top:row*180});}
clips.push({name:clip.name,frame_count:frames.length,loop:clip.loop,preview_fps:clip.fps,timing_authority:'Preview only; preserve current accepted gameplay timing. No new timing contract.',source_map:clip.map,unique_regions:records,frames:stats});row++;
}
await sharp({create:{width:2240,height:900,channels:4,background:'#17232d'}}).composite(contactParts).png().toFile(path.join(out,'all-clips-contact.png'));
for(const file of fs.readdirSync(out).filter(f=>/(_sheet.png|-preview.gif|all-clips-contact.png)$/.test(f))){const p=path.join(out,file),m=await sharp(p,{animated:true}).metadata();outputs.push({file,width:m.width,height:m.height,pageHeight:m.pageHeight,pages:m.pages||1,has_alpha:m.hasAlpha,bytes:fs.statSync(p).size});}
fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify({status:'review-export; visual animation QA pending',cell:spec.cell,feet_anchor:spec.anchor,standing_body_height:180,columns:4,facing:'Right originals, left exact mirrors',total_timeline_frames:34,clips,outputs,validation:{decoded:true,transparent:true,no_nonzero_border:true,engine_import:false,runtime_test:false},provenance:'New generated reinterpretation, not original recovered H3 sprites. Source pose order/repeats referenced; new motion drawings are approximations.'},null,2));
console.log(JSON.stringify(outputs,null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});
