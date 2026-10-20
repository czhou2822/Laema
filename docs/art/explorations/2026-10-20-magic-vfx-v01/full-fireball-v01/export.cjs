const fs=require('fs'),path=require('path'),crypto=require('crypto');
const sharp=require(process.env.LAEMA_ART_SHARP||'sharp');
const source=process.argv[2],backdrop=process.argv[3],root=__dirname;
async function stats(png){const{data,info}=await sharp(png).ensureAlpha().raw().toBuffer({resolveWithObject:true});let x0=info.width,y0=info.height,x1=-1,y1=-1,edge=0,pixels=0;for(let y=0;y<info.height;y++)for(let x=0;x<info.width;x++)if(data[(y*info.width+x)*4+3]>8){x0=Math.min(x0,x);y0=Math.min(y0,y);x1=Math.max(x1,x);y1=Math.max(y1,y);pixels++;if(!x||!y||x===info.width-1||y===info.height-1)edge++;}return{bbox:x1<0?null:[x0,y0,x1+1,y1+1],visible_size:x1<0?[0,0]:[x1-x0+1,y1-y0+1],edge_pixels:edge,visible_pixels:pixels};}
async function gif(frames,w,h,name,delay=90){const raw=[];for(const f of frames)raw.push(await sharp(f).ensureAlpha().raw().toBuffer());await sharp(Buffer.concat(raw),{raw:{width:w,height:h*frames.length,channels:4,pageHeight:h}}).gif({delay:Array(frames.length).fill(delay),loop:0,effort:2,dither:0}).toFile(path.join(root,name));}
async function main(){
fs.copyFileSync(source,path.join(root,'generated-master.png'));const meta=await sharp(source).metadata(),normalized=await sharp(source).resize(1280,1280,{fit:'fill'}).png().toBuffer(),frames=[],checks=[];
fs.mkdirSync(path.join(root,'burst'),{recursive:true});
for(let n=0;n<16;n++){
 const cell=await sharp(normalized).extract({left:n%4*320,top:Math.floor(n/4)*320,width:320,height:320}).png().toBuffer();
 const tile=await sharp(cell).resize(128,128).png().toBuffer(),frame=await sharp({create:{width:256,height:256,channels:4,background:'#00000000'}}).composite([{input:tile,left:64,top:64}]).png().toBuffer();frames.push(frame);checks.push({source_cell:n,source:await stats(cell),export:await stats(frame)});
}
frames.push(await sharp({create:{width:256,height:256,channels:4,background:'#00000000'}}).png().toBuffer());
for(let n=0;n<frames.length;n++)fs.writeFileSync(path.join(root,'burst',String(n).padStart(2,'0')+'.png'),frames[n]);
await sharp({create:{width:256*frames.length,height:256,channels:4,background:'#00000000'}}).composite(frames.map((input,i)=>({input,left:i*256,top:0}))).png().toFile(path.join(root,'burst-strip.png'));
const mattes=[],contacts=[];for(let n=0;n<frames.length;n++){
 const layer=await sharp({create:{width:512,height:256,channels:4,background:'#17202c'}}).composite([{input:Buffer.from('<svg width="256" height="256"><rect width="256" height="256" fill="#eee7da"/></svg>'),left:256,top:0},{input:frames[n],left:0,top:0},{input:frames[n],left:256,top:0}]).png().toBuffer();mattes.push(layer);
 if(n<16)contacts.push({input:layer,left:n%4*512,top:Math.floor(n/4)*256});
}
await gif(mattes,512,256,'burst-dark-light.gif');await sharp({create:{width:2048,height:1024,channels:4,background:'#17202c'}}).composite(contacts).png().toFile(path.join(root,'contact-dark-light.png'));
const title=Buffer.from('<svg width="1280" height="58"><rect width="1280" height="58" fill="#101b2b"/><g font-family="sans-serif"><text x="18" y="25" fill="white" font-size="18">LAEMA · FULL FIREBALL · original Heroes III flame forms adapted to red-orange Fire</text><text x="18" y="47" fill="#bdcad9" font-size="14">Art size proposal · 1280×720 · static actors · timing illustrative · no gameplay level or area assigned · no engine run</text></g></svg>');
const scene=[];for(let n=0;n<25;n++){const layers=[{input:title,left:0,top:0}];if(n<frames.length)layers.push({input:frames[n],left:626,top:382});scene.push(await sharp(backdrop).composite(layers).png().toBuffer());}
await gif(scene,1280,720,'gameplay-scale.gif');fs.writeFileSync(path.join(root,'gameplay-scale-peak.png'),scene[5]);
// Native-scale size comparison with the separate Level 1 mini candidate.
const mini=path.join(root,'..','mini-fireball-level1-v01','travel','03.png');
const compareBase=Buffer.from('<svg width="720" height="290"><rect width="720" height="290" fill="#17202c"/><g fill="white" font-family="sans-serif" font-size="18"><text x="30" y="35">Level 1 mini</text><text x="350" y="35">Full Fireball art study</text><text x="30" y="270" font-size="14">Native preview sizes only. No gameplay level / damage / area rule inferred.</text></g></svg>');
await sharp(compareBase).composite([{input:await sharp(mini).png().toBuffer(),left:40,top:80},{input:frames[5],left:330,top:2}]).png().toFile(path.join(root,'mini-versus-full.png'));
const files=[];for(const name of['generated-master.png','burst-strip.png','burst-dark-light.gif','contact-dark-light.png','gameplay-scale.gif','gameplay-scale-peak.png','mini-versus-full.png']){const b=fs.readFileSync(path.join(root,name)),m=await sharp(b,{animated:true}).metadata();files.push({file:name,sha256:crypto.createHash('sha256').update(b).digest('hex'),width:m.width,height:m.pageHeight||m.height,frames:m.pages||1,alpha:m.hasAlpha});}
fs.writeFileSync(path.join(root,'manifest.json'),JSON.stringify({status:'Art candidate; user visual acceptance pending',department:'Art',scope:'Full Fireball visual adaptation, no Laema gameplay level assigned',source_reference:'docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/C13SPF/group_00_block_00_page_00.png',source_def_sha256:'251b03415e8dd334c350a728b6ee1b901fdfc55b96b5b149d3dc5b596f6e297a',original_frame_count:13,generation:'built-in image_gen, reference-based generated adaptation, followed by padding repair',generated_file:path.basename(source),master_dimensions:[meta.width,meta.height],cell:[256,256],pivot:[128,128],frame_count:17,loop:false,last_frame:'transparent mechanical endpoint',preview_frame_ms:90,timing:'illustrative',engine_validated:false,runtime_imported:false,checks,files},null,2)+'\n');
console.log(JSON.stringify({source_edges:checks.map(x=>x.source.edge_pixels),sizes:checks.map(x=>x.export.visible_size)}));
}
main().catch(e=>{console.error(e);process.exitCode=1});
