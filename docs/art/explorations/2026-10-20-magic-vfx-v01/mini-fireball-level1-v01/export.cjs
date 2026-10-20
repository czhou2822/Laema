const fs=require('fs'),path=require('path'),crypto=require('crypto');
const sharp=require(process.env.LAEMA_ART_SHARP || 'sharp');
const root=__dirname;
const source=process.argv[2],backdrop=process.argv[3];
if(!source||!backdrop)throw Error('Provide generated PNG and approved static review backdrop paths');
async function stats(png){const {data,info}=await sharp(png).ensureAlpha().raw().toBuffer({resolveWithObject:true});let x0=info.width,y0=info.height,x1=-1,y1=-1,edge=0,pixels=0;for(let y=0;y<info.height;y++)for(let x=0;x<info.width;x++){if(data[(y*info.width+x)*4+3]>8){x0=Math.min(x0,x);y0=Math.min(y0,y);x1=Math.max(x1,x);y1=Math.max(y1,y);pixels++;if(!x||!y||x===info.width-1||y===info.height-1)edge++;}}return {bbox:x1<0?null:[x0,y0,x1+1,y1+1],visible_size:x1<0?[0,0]:[x1-x0+1,y1-y0+1],visible_pixels:pixels,edge_pixels:edge};}
async function gif(frames,w,h,file,ms){const raw=[];for(const f of frames)raw.push(await sharp(f).ensureAlpha().raw().toBuffer());await sharp(Buffer.concat(raw),{raw:{width:w,height:h*frames.length,channels:4,pageHeight:h}}).gif({delay:Array(frames.length).fill(ms),loop:0,effort:2,dither:0}).toFile(path.join(root,file));}
async function main(){
fs.copyFileSync(source,path.join(root,'generated-master.png'));
const meta=await sharp(source).metadata();const normalized=await sharp(source).resize(1280,1280,{fit:'fill'}).png().toBuffer();
const roles={travel:[],impact:[]},checks=[];
for(let n=0;n<16;n++){
 const role=n<8?'travel':'impact',size=role==='travel'?64:72;
 const sourceCell=await sharp(normalized).extract({left:n%4*320,top:Math.floor(n/4)*320,width:320,height:320}).png().toBuffer();
 const tile=await sharp(sourceCell).resize(size,size).png().toBuffer();
 const frame=await sharp({create:{width:128,height:128,channels:4,background:'#00000000'}}).composite([{input:tile,left:(128-size)/2,top:(128-size)/2}]).png().toBuffer();
 roles[role].push(frame);checks.push({source_cell:n,role,sourceCell:await stats(sourceCell),export:await stats(frame)});
}
roles.impact.push(await sharp({create:{width:128,height:128,channels:4,background:'#00000000'}}).png().toBuffer());
for(const [role,frames]of Object.entries(roles)){
 const dir=path.join(root,role);fs.mkdirSync(dir,{recursive:true});for(let i=0;i<frames.length;i++)fs.writeFileSync(path.join(dir,String(i).padStart(2,'0')+'.png'),frames[i]);
 await sharp({create:{width:128*frames.length,height:128,channels:4,background:'#00000000'}}).composite(frames.map((input,i)=>({input,left:i*128,top:0}))).png().toFile(path.join(root,role+'-strip.png'));
 const previews=[];for(const frame of frames)previews.push(await sharp({create:{width:256,height:128,channels:4,background:'#17202c'}}).composite([{input:Buffer.from('<svg width="128" height="128"><rect width="128" height="128" fill="#eee7da"/></svg>'),left:128,top:0},{input:frame,left:0,top:0},{input:frame,left:128,top:0}]).png().toBuffer());
 await gif(previews,256,128,role+'-dark-light.gif',90);
}
const contact=[];for(let n=0;n<16;n++)for(let side=0;side<2;side++){
 const frame=n<8?roles.travel[n]:roles.impact[n-8],bg=side?'#eee7da':'#17202c';
 contact.push({input:await sharp({create:{width:128,height:128,channels:4,background:bg}}).composite([{input:frame}]).png().toBuffer(),left:n%4*128+side*512,top:Math.floor(n/4)*128});
}
await sharp({create:{width:1024,height:512,channels:4,background:'#17202c'}}).composite(contact).png().toFile(path.join(root,'contact-dark-light.png'));
const title=Buffer.from('<svg width="1280" height="58"><rect width="1280" height="58" fill="#101b2b"/><g font-family="sans-serif"><text x="18" y="25" fill="white" font-size="18">LEVEL 1 FIRE · MINI FIREBALL · inspired by Heroes III Level 3 Fireball</text><text x="18" y="47" fill="#bdcad9" font-size="14">Art proposal · 1280×720 · intended 180px body / feet y610 · static backdrop · illustrative timing · no engine run</text></g></svg>');
const scene=[];for(let n=0;n<25;n++){
 let layers=[{input:title,left:0,top:0}];
 if(n<8)layers.push({input:roles.travel[n],left:465+Math.round(n*30),top:446});
 else if(n<17)layers.push({input:roles.impact[n-8],left:690,top:446});
 scene.push(await sharp(backdrop).composite(layers).png().toBuffer());
}
await gif(scene,1280,720,'gameplay-scale.gif',90);fs.writeFileSync(path.join(root,'gameplay-scale-peak.png'),scene[10]);
// A held-in-place loop isolates generated surface motion from scene travel.
const loop=[];for(const frame of roles.travel)loop.push(await sharp({create:{width:256,height:256,channels:4,background:'#17202c'}}).composite([{input:await sharp(frame).resize(256,256,{kernel:'nearest'}).png().toBuffer()}]).png().toBuffer());
await gif(loop,256,256,'travel-2x-inspection.gif',90);
const records=[];for(const filename of ['generated-master.png','travel-strip.png','impact-strip.png','contact-dark-light.png','gameplay-scale.gif','gameplay-scale-peak.png','travel-dark-light.gif','impact-dark-light.gif','travel-2x-inspection.gif']){const data=fs.readFileSync(path.join(root,filename)),m=await sharp(data,{animated:true}).metadata();records.push({filename,sha256:crypto.createHash('sha256').update(data).digest('hex'),width:m.width,height:m.pageHeight||m.height,frames:m.pages||1,alpha:m.hasAlpha});}
fs.writeFileSync(path.join(root,'manifest.json'),JSON.stringify({status:'User-directed art candidate; visual acceptance pending',department:'Art',purpose:'Level 1 Fire mini fireball presentation',source_reference:'docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/C13SPF/group_00_block_00_page_00.png',source_def_sha256:'251b03415e8dd334c350a728b6ee1b901fdfc55b96b5b149d3dc5b596f6e297a',generated_file:path.basename(source),generation:'built-in image_gen; source-referenced generated adaptation',master_dimensions:[meta.width,meta.height],normalized_grid:[4,4],cell:[128,128],pivot:[64,64],travel:{frames:8,loop:true},impact:{frames:9,loop:false,last_frame:'transparent mechanical endpoint'},preview_ms:90,timing:'illustrative only',runtime_imported:false,engine_validated:false,checks,files:records},null,2)+'\n');
console.log(JSON.stringify({travel:checks.slice(0,8).map(x=>x.export.visible_size),impact:checks.slice(8).map(x=>x.export.visible_size),source_edges:checks.map(x=>x.sourceCell.edge_pixels),files:records.map(x=>({filename:x.filename,frames:x.frames}))}));
}
main().catch(e=>{console.error(e);process.exitCode=1});
