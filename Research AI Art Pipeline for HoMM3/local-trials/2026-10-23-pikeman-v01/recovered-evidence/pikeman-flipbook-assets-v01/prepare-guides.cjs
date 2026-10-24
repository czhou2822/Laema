const fs=require('fs'),path=require('path');
const sharp=require('C:/Users/zhouc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const root='C:/Users/zhouc/OneDrive/Documents/ChatGPT/Laema';
const out=__dirname;
const definitions=[{name:'idle',file:'Idle.png',group:2,count:7,rows:3},{name:'walk',file:'Walk.png',group:0,count:6,rows:2},{name:'attack',file:'Attack.png',group:12,count:10,rows:4},{name:'hurt',file:'Hurt.png',group:3,count:6,rows:2},{name:'death',file:'Dead.png',group:5,count:5,rows:2}];
async function main(){
 const meta=JSON.parse(fs.readFileSync(path.join(root,'docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CPKMAN/metadata.json'),'utf8'));
 await sharp('C:/Users/zhouc/.codex/visualizations/2026/09/08/01a07f41-7159-70f1-ac7d-e6217941c130/pikeman-sprite-assets-v01/pikeman_idle_master_rgba.png').flop().png().toFile(path.join(out,'master-right-reference.png'));
 for(const def of definitions){
  const group=meta.groups.find(g=>g.id===def.group),parts=[];
  const src=path.join(root,'assets/prototype/enemy/pikeman',def.file);
  const scale=240/73;
  for(let i=0;i<def.count;i++){
   const frame=await sharp(src).extract({left:(i%4)*450,top:Math.floor(i/4)*400,width:450,height:400}).ensureAlpha().raw().toBuffer({resolveWithObject:true});
   let x0=450,y0=400,x1=-1,y1=-1;
   for(let y=0;y<400;y++)for(let x=0;x<450;x++)if(frame.data[(y*450+x)*4+3]>=128){x0=Math.min(x0,x);y0=Math.min(y0,y);x1=Math.max(x1,x);y1=Math.max(y1,y);}
   x0=Math.max(0,x0-2);y0=Math.max(0,y0-2);x1=Math.min(449,x1+2);y1=Math.min(399,y1+2);
   const cut=await sharp(frame.data,{raw:frame.info}).extract({left:x0,top:y0,width:x1-x0+1,height:y1-y0+1}).resize(Math.round((x1-x0+1)*scale),Math.round((y1-y0+1)*scale),{kernel:'nearest'}).png().toBuffer();
   const cellLeft=Math.round(384+(x0-196)*scale),cellTop=Math.round(350+(y0-268)*scale);
   parts.push({input:cut,left:(i%3)*768+cellLeft,top:Math.floor(i/3)*384+cellTop});
  }
  let labels='<svg xmlns="http://www.w3.org/2000/svg" width="2304" height="'+(def.rows*384)+'">';
  for(let i=0;i<def.rows*3;i++){
   const x=(i%3)*768,y=Math.floor(i/3)*384;
   labels+='<rect x="'+(x+1)+'" y="'+(y+1)+'" width="766" height="382" fill="none" stroke="#53616d" stroke-width="2"/>';
   labels+='<text x="'+(x+14)+'" y="'+(y+30)+'" font-family="Arial" font-size="24" fill="#d6e2ec">'+(i<def.count?'FRAME '+String(i+1).padStart(2,'0'):'EMPTY')+'</text>';
   labels+='<line x1="'+(x+310)+'" y1="'+(y+350)+'" x2="'+(x+458)+'" y2="'+(y+350)+'" stroke="#627a63" stroke-width="1"/>';
  }
  labels+='</svg>';
  const guide=path.join(out,def.name+'-pose-guide.png');
  await sharp({create:{width:2304,height:def.rows*384,channels:4,background:'#303944'}}).composite([{input:Buffer.from(labels)},...parts]).png().toFile(guide);
  def.guide=guide;def.source=src;def.source_frames=group.frames.map(f=>({index:f.index,name:f.name,left:f.left,top:f.top,width:f.width,height:f.height}));
 }
 fs.writeFileSync(path.join(out,'source-pose-guides.json'),JSON.stringify({guide_cell:[768,384],guide_columns:3,guide_anchor:[384,350],guide_body_target:240,source_anchor:[196,268],source_body_reference:73,source_facing:'right',clips:definitions},null,2)+'\n');
 console.log(JSON.stringify(definitions.map(d=>({name:d.name,count:d.count,guide:d.guide}))));
}
main().catch(e=>{console.error(e);process.exitCode=1;});

