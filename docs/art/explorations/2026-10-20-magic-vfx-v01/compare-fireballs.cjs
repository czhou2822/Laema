const fs=require('fs'),path=require('path');
const sharp=require(process.env.LAEMA_ART_SHARP||'sharp');
const root=__dirname,w=800,h=380;
async function main(){
const miniTravel=[],miniImpact=[],full=[];
for(let i=0;i<8;i++)miniTravel.push(fs.readFileSync(path.join(root,'mini-fireball-level1-v01','travel',String(i).padStart(2,'0')+'.png')));
for(let i=0;i<9;i++)miniImpact.push(fs.readFileSync(path.join(root,'mini-fireball-level1-v01','impact',String(i).padStart(2,'0')+'.png')));
for(let i=0;i<17;i++)full.push(fs.readFileSync(path.join(root,'full-fireball-v01','burst',String(i).padStart(2,'0')+'.png')));
const base=Buffer.from('<svg width="800" height="380"><rect width="800" height="380" fill="#17202c"/><path d="M400 74V304" stroke="#566475"/><g font-family="sans-serif" fill="#f4f4f4"><text x="28" y="34" font-size="23">Level 1 mini fireball</text><text x="438" y="34" font-size="23">Full Fireball study</text><text x="28" y="59" font-size="15">32px flight · 52px peak impact</text><text x="438" y="59" font-size="15">105px peak burst</text><text x="28" y="340" font-size="16">Same native pixel scale · peak bursts aligned for this comparison</text><text x="28" y="365" font-size="14" fill="#bac8d7">Art candidates · review timing illustrative · no engine run</text></g><path d="M380 100h-8m8 0v180m0 0h-8" stroke="#a7b8cb" fill="none"/><text x="367" y="193" font-family="sans-serif" fill="#a7b8cb" font-size="12" text-anchor="end">180px</text></svg>');
const raw=[];for(let n=0;n<27;n++){
const layers=[];
if(n<3)layers.push({input:miniTravel[n],left:136,top:126});
else if(n<12)layers.push({input:miniImpact[n-3],left:136,top:126});
if(n<17)layers.push({input:full[n],left:472,top:62});
const frame=await sharp(base).composite(layers).png().toBuffer();if(n===5)fs.writeFileSync(path.join(root,'mini-versus-full-peak.png'),frame);raw.push(await sharp(frame).ensureAlpha().raw().toBuffer());
}
await sharp(Buffer.concat(raw),{raw:{width:w,height:h*raw.length,channels:4,pageHeight:h}}).gif({delay:Array(raw.length).fill(90),loop:0,effort:2,dither:0}).toFile(path.join(root,'mini-versus-full.gif'));
console.log('Side-by-side Fireball comparison exported');
}
main().catch(e=>{console.error(e);process.exitCode=1});
