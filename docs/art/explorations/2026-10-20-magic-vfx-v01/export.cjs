const fs=require('fs'),path=require('path'),crypto=require('crypto');
const sharp=require('C:/Users/zhouc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root=__dirname;
const sourceRoot='C:/Users/zhouc/.codex/generated_images/01a15802-bee8-7fa3-a19e-b4751e6f279b';
const mockup='C:/Users/zhouc/.codex/visualizations/2026/09/08/01a07f41-7159-70f1-ac7d-e6217941c130/town-edge-yard-framing-round-02/mockup-05.png';
const schools=JSON.parse(fs.readFileSync(path.join(root,'sources.json'),'utf8'));
const blank=()=>sharp({create:{width:128,height:128,channels:4,background:'#00000000'}});
const svg=(text,w=1280,h=56)=>Buffer.from(`<svg width="${w}" height="${h}"><rect width="100%" height="100%" fill="#101b2b"/><text x="18" y="24" fill="white" font-size="18" font-family="sans-serif">${text}</text><text x="18" y="46" fill="#bdcad9" font-size="14" font-family="sans-serif">ART PREVIEW · 1280×720 · timing illustrative · static actor scale reference · no engine run</text></svg>`);
async function gif(frames,w,h,file,delay=90){
 const raw=[];for(const f of frames)raw.push(await sharp(f).ensureAlpha().raw().toBuffer());
 await sharp(Buffer.concat(raw),{raw:{width:w,height:h*frames.length,channels:4,pageHeight:h}}).gif({delay:Array(frames.length).fill(delay),loop:0,effort:7,dither:0}).toFile(file);
}
async function sheet(frames,file){await sharp({create:{width:128*frames.length,height:128,channels:4,background:'#00000000'}}).composite(frames.map((input,i)=>({input,left:i*128,top:0}))).png().toFile(file);}
async function bounds(buffer){const {data,info}=await sharp(buffer).ensureAlpha().raw().toBuffer({resolveWithObject:true});let x0=info.width,y0=info.height,x1=-1,y1=-1,edge=0,pixels=0;for(let y=0;y<info.height;y++)for(let x=0;x<info.width;x++){if(data[(y*info.width+x)*4+3]>8){x0=Math.min(x0,x);x1=Math.max(x1,x);y0=Math.min(y0,y);y1=Math.max(y1,y);pixels++;if(x===0||y===0||x===info.width-1||y===info.height-1)edge++;}}return {bbox:x1<0?null:[x0,y0,x1+1,y1+1],edge_pixels:edge,visible_pixels:pixels};}
async function main(){
 const report=[];
 for(const [school,src] of Object.entries(schools)){
  const dir=path.join(root,school);fs.mkdirSync(dir,{recursive:true});
  const source=path.join(sourceRoot,src);fs.copyFileSync(source,path.join(dir,'generated-master.png'));
  const meta=await sharp(source).metadata();if(meta.width!==meta.height)throw Error('Atlas not square 4x4');
  const normalized=await sharp(source).resize(1280,1280).png().toBuffer();
  const c=320;const roles={cast:[],travel:[],impact:[]};const records=[];
  for(let n=0;n<16;n++){
   const role=n<4?'cast':n<8?'travel':'impact';
   const size=role==='travel'?80:96;
   const tile=await sharp(normalized).extract({left:(n%4)*c,top:Math.floor(n/4)*c,width:c,height:c}).resize(size,size).png().toBuffer();
   const frame=await blank().composite([{input:tile,left:(128-size)/2,top:(128-size)/2}]).png().toBuffer();
   roles[role].push(frame);records.push({source_cell:n,role,...await bounds(frame)});
  }
  // Explicit transparent endpoints are export frames, not newly generated poses.
  const empty=await blank().png().toBuffer();roles.cast=[empty,...roles.cast,empty];roles.impact=[...roles.impact,empty];
  for(const [role,frames]of Object.entries(roles)){
   const fd=path.join(dir,role);fs.mkdirSync(fd,{recursive:true});
   for(let i=0;i<frames.length;i++)fs.writeFileSync(path.join(fd,String(i).padStart(2,'0')+'.png'),frames[i]);
   await sheet(frames,path.join(dir,role+'-strip.png'));
   const matteFrames=[];for(const frame of frames)matteFrames.push(await sharp({create:{width:128,height:128,channels:4,background:'#23303e'}}).composite([{input:frame}]).png().toBuffer());
   await gif(matteFrames,128,128,path.join(dir,role+'-preview.gif'));
  }
  const mats=[];for(const bg of ['#101923','#eee7da'])for(let n=0;n<16;n++){
    const role=n<4?'cast':n<8?'travel':'impact',offset=role==='cast'?1:0,index=n<4?n:n<8?n-4:n-8;
    mats.push({input:await sharp({create:{width:128,height:128,channels:4,background:bg}}).composite([{input:roles[role][index+offset]}]).png().toBuffer(),left:(n%4)*128+(bg==='#eee7da'?512:0),top:Math.floor(n/4)*128});
  }
  await sharp({create:{width:1024,height:512,channels:4,background:'#101923'}}).composite(mats).png().toFile(path.join(dir,'contact-dark-light.png'));
  const scene=[];for(let n=0;n<26;n++){
    const layers=[{input:svg(school.toUpperCase()+' / separate cast accent, travel, impact proposals'),left:0,top:0}];
    if(n<6)layers.push({input:roles.cast[n],left:465,top:446});
    else if(n<12)layers.push({input:roles.travel[(n-6)%4],left:465+Math.round((n-6)*42.67),top:446});
    else if(n<21)layers.push({input:roles.impact[n-12],left:690,top:446});
    scene.push(await sharp(mockup).composite(layers).png().toBuffer());
  }
  await gif(scene,1280,720,path.join(dir,'gameplay-scale.gif'),70);
  fs.writeFileSync(path.join(dir,'gameplay-scale-peak.png'),scene[14]);
  report.push({school,master:{width:meta.width,height:meta.height,hasAlpha:meta.hasAlpha},cell:[128,128],pivot:[64,64],cast_frames:6,travel_frames:4,impact_frames:9,loop:{cast:false,travel:true,impact:false},preview_frame_ms:90,scene_frame_ms:70,frames:records});
 }
 fs.writeFileSync(path.join(root,'geometry-and-alpha.json'),JSON.stringify(report,null,2)+'\n');
 console.log(JSON.stringify(report.map(x=>({school:x.school,alpha:x.master.hasAlpha,edgePixels:x.frames.reduce((a,f)=>a+f.edge_pixels,0)}))));
}
main().catch(e=>{console.error(e);process.exitCode=1});
