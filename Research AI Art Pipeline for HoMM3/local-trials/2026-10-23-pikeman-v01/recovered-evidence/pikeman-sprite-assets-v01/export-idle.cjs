const fs=require('fs');
const path=require('path');
const crypto=require('crypto');
const sharp=require('C:/Users/zhouc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const out=__dirname;
const spec=JSON.parse(fs.readFileSync(path.join(out,'asset-spec.json'),'utf8'));
async function main(){
  const {data,info}=await sharp(spec.source).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  const pixels=Buffer.from(data);
  let minX=info.width,minY=info.height,maxX=-1,maxY=-1;
  for(let y=0;y<info.height;y++)for(let x=0;x<info.width;x++){
    const i=(y*info.width+x)*4;
    const a=pixels[i+3];
    if(a<=2){pixels[i]=0;pixels[i+1]=0;pixels[i+2]=0;pixels[i+3]=0;}
    else if(a>=240)pixels[i+3]=255;
    if(a>=128){minX=Math.min(minX,x);minY=Math.min(minY,y);maxX=Math.max(maxX,x);maxY=Math.max(maxY,y);}
  }
  if(maxX<0)throw new Error('Empty opaque subject');
  const x0=Math.max(0,minX-4),y0=Math.max(0,minY-4);
  const x1=Math.min(info.width,maxX+5),y1=Math.min(info.height,maxY+5);
  const sourceSole=maxY+1;
  const bodyHeight=sourceSole-spec.body_crown_source_y;
  const scale=spec.standing_body_height/bodyHeight;
  const crop=await sharp(pixels,{raw:info}).extract({left:x0,top:y0,width:x1-x0,height:y1-y0}).png().toBuffer();
  fs.writeFileSync(path.join(out,'pikeman_idle_master_rgba.png'),crop);
  const w=Math.round((x1-x0)*scale),h=Math.round((y1-y0)*scale);
  const sprite=await sharp(crop).resize(w,h,{kernel:'lanczos3'}).png().toBuffer();
  const anchor=[Math.round((spec.feet_center_source_x-x0)*scale),Math.round((sourceSole-y0)*scale)];
  const left=spec.feet_anchor[0]-anchor[0],top=spec.feet_anchor[1]-anchor[1];
  const frame=await sharp({create:{width:768,height:512,channels:4,background:{r:0,g:0,b:0,alpha:0}}})
    .composite([{input:sprite,left,top}]).png().toBuffer();
  fs.writeFileSync(path.join(out,'idle_left_frame_00.png'),frame);
  await sharp(frame).flop().png().toFile(path.join(out,'idle_right_frame_00.png'));
  const {data:frameData,info:frameInfo}=await sharp(frame).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  let transparent=0,opaque=0,partial=0,borderPixels=0;
  for(let y=0;y<frameInfo.height;y++)for(let x=0;x<frameInfo.width;x++){
    const a=frameData[(y*frameInfo.width+x)*4+3];
    if(a===0)transparent++;else if(a===255)opaque++;else partial++;
    if((x===0||y===0||x===767||y===511)&&a)borderPixels++;
  }
  if(!transparent||!opaque||borderPixels)throw new Error('Export alpha/margin verification failed');
  const colours=['#e9e7e1','#142133'];
  const previews=[];
  for(let i=0;i<colours.length;i++){
    const clipped=await sharp(frame).extract({left:280,top:200,width:230,height:270})
      .flatten({background:colours[i]}).png().toBuffer();
    previews.push({input:clipped,left:20+i*250,top:65});
  }
  let svg='<svg xmlns="http://www.w3.org/2000/svg" width="520" height="380"><rect width="520" height="380" fill="#101925"/><text x="20" y="34" font-family="Arial" font-size="22" font-weight="700" fill="#f2ead7">PIKEMAN / ACTUAL TRANSPARENT IDLE</text><text x="20" y="360" font-family="Arial" font-size="16" fill="#b8c9d7">180 px body · light/dark matte checks · one frame</text></svg>';
  await sharp(Buffer.from(svg)).composite(previews).png().toFile(path.join(out,'idle_asset_preview.png'));
  const outputs=[];
  for(const filename of ['pikeman_idle_master_rgba.png','idle_left_frame_00.png','idle_right_frame_00.png','idle_asset_preview.png']){
    const p=path.join(out,filename),meta=await sharp(p).metadata();
    outputs.push({file:filename,width:meta.width,height:meta.height,channels:meta.channels,has_alpha:meta.hasAlpha,bytes:fs.statSync(p).size,sha256:crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex')});
  }
  const result={
    status:'First static sprite asset exported; animation set not complete',
    inputs:spec,
    source_opaque_bounds:{left:minX,top:minY,right:maxX+1,bottom:maxY+1},
    master_crop:{left:x0,top:y0,width:x1-x0,height:y1-y0},
    source_body_landmarks:{crown_y:spec.body_crown_source_y,sole_y:sourceSole,body_height:bodyHeight,method:'Crown from visual inspection; sole from opaque alpha bounds'},
    frame:{width:768,height:512,feet_anchor:spec.feet_anchor,standing_body_height_px:180,source_facing:'left',right_facing_is_exact_mirror:true,frame_count:1},
    alpha_policy:'Export: alpha<=2 clears stray nearly invisible pixels and RGB; alpha>=240 made opaque; intermediate silhouette alpha retained. Original generation remains unmodified at its saved source path.',
    checks:{pngs_decoded:true,frame_transparent_pixels:transparent,frame_opaque_pixels:opaque,frame_edge_pixels:partial,nonzero_alpha_on_canvas_border:borderPixels,engine_run:false},
    outputs,
    original_animation_coverage_still_needed:{idle:7,walk:6,front_thrust:10,hurt:6,death:5,total:34},
    provenance:'New generated reinterpretation based on user-approved mockup and original Heroes III Pikeman reference. Not an authentic recovered original sprite.'
  };
  fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify(result,null,2)+'\n');
  console.log(JSON.stringify(result,null,2));
}
main().catch(e=>{console.error(e);process.exitCode=1;});

