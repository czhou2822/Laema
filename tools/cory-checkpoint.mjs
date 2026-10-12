// Shared, bounded transport contract. No source files, credentials, or raw logs.
const text = (maxLength=500) => ({type:'string',maxLength});
const choice = values => ({type:'string',enum:values});
const object = (properties, required=Object.keys(properties)) => ({type:'object',properties,required,additionalProperties:false});
const list = (items,maxItems=30) => ({type:'array',items,maxItems});
const url = {...text(1500),format:'github-url'};
const date = {...text(40),format:'date-time'};
const sha = {...text(64),pattern:'^[a-fA-F0-9]{40,64}$'};
const repoName = {...text(200),pattern:'^[A-Za-z0-9][A-Za-z0-9-]{0,38}/[A-Za-z0-9_.-]{1,100}$'};
const nullable = value => ({anyOf:[value,{type:'null'}]});
const integer = {type:'integer',minimum:0,maximum:Number.MAX_SAFE_INTEGER};
const categories = ['playtest','design','bug','decision','implementing','integration'];
const sourceKeys = ['repositories','commits','pulls','runs','branches','issues','director','checks','tests'];
const snapshotSchema = object({
  observedAt:date,
  repositories:list(object({fullName:repoName,defaultBranch:text(250),visibility:choice(['public','private','internal','unknown']),url}),100),
  selected:nullable(repoName),
  sources:list(object({key:choice(sourceKeys),status:choice(['ok','partial','unavailable','forbidden','error']),url:nullable(url),observedAt:date,message:text(1000)}),sourceKeys.length),
  commits:list(object({sha,title:text(),url,at:date}),20),
  pulls:list(object({number:integer,title:text(),url,draft:{type:'boolean'},headSha:sha,headBranch:text(250),baseBranch:text(250),review:choice(['unknown','approved','changes_requested','commented','pending']),technical:choice(['unknown','pass','fail','pending'])})),
  runs:list(object({id:integer,title:text(),url,status:text(60),conclusion:nullable(text(60)),sha,branch:text(250),at:date,failures:list(object({title:text(),url,summary:text(2000)}),10)}),20),
  checks:list(object({name:text(),status:text(60),conclusion:nullable(text(60)),sha,url,summary:text(2000)}),30),
  tests:list(object({title:text(),result:choice(['passed','failed','unknown']),sha,url,summary:text(1000)}),20),
  branches:list(object({name:text(250),sha,url,ahead:nullable(integer),behind:nullable(integer),compareUrl:nullable(url)}),50),
  director:list(object({category:choice(categories),title:text(),url,statement:text(1500),status:choice(['pending','accepted','rejected','unknown']),evidenceAt:nullable(date),evidenceSha:nullable(sha)}),50)
});
const identifier={...text(100),pattern:'^[A-Za-z0-9_-]+$'};
const departmentNames={combat:'Combat',narrative:'Narrative',town_design:'Town Design',marketing:'Marketing',art:'Art',design_overseer:'Design Overseer',audio:'Audio',other:'Other'};
const departmentKeys=Object.keys(departmentNames);
const departmentContextSchema=object({repository:repoName,observedAt:date,records:list(object({key:choice(departmentKeys),markdown:text(8000),sourceFile:text(400),source:choice(['local_unpublished','checkpoint']),coverage:text(600),uid:nullable(sha)},['key','markdown','sourceFile','source','coverage']),8)});
const threadContextSchema=object({
  repository:repoName,projectId:identifier,projectName:text(200),scope:choice(['all_unarchived']),observedAt:date,
  discovery:choice(['complete','partial','unavailable','error']),discoveredCount:integer,message:text(1200),
  threads:list(object({
    id:identifier,title:nullable(text(250)),kind:choice(['codex','chatgpt']),hostId:nullable(identifier),
    projectId:nullable(identifier),membership:choice(['project_id','working_directory']),activity:text(80),
    updatedAt:nullable(date),observedAt:date,readState:choice(['read','partial','unavailable','error']),
    context:text(2000),decisions:list(text(400),5),openItems:list(text(400),5),resumePoint:text(1000),
    coverage:text(600),turnsRead:integer,hasOlder:nullable({type:'boolean'}),
    taskKey:nullable(identifier),aliases:list(text(250),20),progressUid:nullable(text(150)),knownThreadIds:list(identifier,30),departmentKey:nullable(choice(departmentKeys))
  },['id','title','kind','hostId','projectId','membership','activity','updatedAt','observedAt','readState','context','decisions','openItems','resumePoint','coverage','turnsRead','hasOlder']),200)
});
const reconciledContextSchema=object({carriedId:identifier,currentId:identifier,matchEvidence:text(600),context:text(2000),resumePoint:text(1000),conflicts:list(text(600),10),notes:list(text(600),10)});
const checkpointReviewSchema=object({repository:repoName,action:choice(['save','load']),state:choice(['ready','blocked','partial','no_changes']),observedAt:date,paths:list(text(500),2000),message:text(3000),localHead:nullable(sha),depotHead:nullable(sha),workingDigest:nullable(sha)});
const inputSchema = object({snapshot:snapshotSchema,threadContext:threadContextSchema,carriedThreadContext:threadContextSchema,reconciledContexts:list(reconciledContextSchema,200),departmentContext:departmentContextSchema,checkpointReview:checkpointReviewSchema},[]);

function validate(value,schema,path='$') {
  if(schema.anyOf) {
    for(const item of schema.anyOf) {try {validate(value,item,path);return;} catch {}}
    throw new Error(path+': invalid value');
  }
  const type=value===null?'null':Array.isArray(value)?'array':typeof value;
  if(schema.type==='integer' ? !Number.isSafeInteger(value) : type!==schema.type) throw new Error(path+': expected '+schema.type);
  if(schema.enum && !schema.enum.includes(value)) throw new Error(path+': unsupported value');
  if(type==='string') {
    if(value.length>(schema.maxLength??Infinity)) throw new Error(path+': text too long');
    if(schema.pattern && !new RegExp(schema.pattern).test(value)) throw new Error(path+': invalid format');
    if(schema.format==='date-time' && (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$/.test(value) || !Number.isFinite(Date.parse(value)))) throw new Error(path+': use a UTC timestamp');
    if(schema.format==='github-url' && !safeGithubUrl(value)) throw new Error(path+': use a GitHub HTTPS link');
  }
  if(type==='number' && (value<schema.minimum || value>schema.maximum)) throw new Error(path+': out of range');
  if(type==='array') {
    if(value.length>schema.maxItems) throw new Error(path+': too many items');
    value.forEach((x,i)=>validate(x,schema.items,path+'['+i+']'));
  }
  if(type==='object') {
    for(const key of schema.required??[]) if(!Object.hasOwn(value,key)) throw new Error(path+'.'+key+': missing');
    for(const [key,item] of Object.entries(value)) {
      if(!Object.hasOwn(schema.properties,key)) throw new Error(path+': unexpected field');
      validate(item,schema.properties[key],path+'.'+key);
    }
  }
}
function safeGithubUrl(value) {
  try {const u=new URL(value);return u.protocol==='https:' && ['github.com','api.github.com'].includes(u.hostname) && !u.username && !u.password && !u.port && !/[\u0000-\u0020\u007f]/.test(value);} catch{return false;}
}
function normalizeInput(input,now=new Date()) {
  validate(input,inputSchema);
  const threadContext=input.threadContext?normalizeThreadContext(input.threadContext,input.snapshot?.selected??null,now):null;
  const carriedThreadContext=input.carriedThreadContext?normalizeThreadContext(input.carriedThreadContext,input.snapshot?.selected??threadContext?.repository??null,now):null;
  if(input.reconciledContexts?.length && (!threadContext||!carriedThreadContext))throw new Error('Reconciliation needs both carried and current context');
  const reconciledContexts=structuredClone(input.reconciledContexts??[]);
  const reconciliation=carriedThreadContext&&threadContext?reconcileThreads(carriedThreadContext,threadContext,reconciledContexts):null;
  const departmentContext=input.departmentContext?normalizeDepartmentContext(input.departmentContext,input.snapshot?.selected??threadContext?.repository??carriedThreadContext?.repository??null,now):null;
  const checkpointReview=input.checkpointReview?normalizeCheckpointReview(input.checkpointReview,input.snapshot?.selected??threadContext?.repository??departmentContext?.repository??null,now):null;
  const contextData={threadContext,carriedThreadContext,reconciledContexts,reconciliation,departmentContext,checkpointReview};
  if(!input.snapshot) return {snapshot:null,...contextData,local:{connected:false},mode:'chat-mediated',version:'0.2.0'};
  const s=structuredClone(input.snapshot);
  if(Date.parse(s.observedAt)>now.getTime()+60000) throw new Error('Snapshot timestamp is in the future');
  if(s.selected!==null && !s.repositories.some(r=>r.fullName===s.selected)) throw new Error('Selected repository must be verified in this read');
  if(s.selected===null && ['commits','pulls','runs','checks','tests','branches','director'].some(k=>s[k].length)) throw new Error('Repository data requires a selection');
  if(new Set(s.repositories.map(r=>r.fullName.toLowerCase())).size!==s.repositories.length) throw new Error('Duplicate repositories');
  if(new Set(s.sources.map(r=>r.key)).size!==s.sources.length) throw new Error('Duplicate sources');
  for(const r of s.repositories) assertRepoUrl(r.url,r.fullName);
  for(const source of s.sources) {
    if(Date.parse(source.observedAt)>now.getTime()+60000) throw new Error('Source timestamp is in the future');
    if(source.url && source.key!=='repositories') assertRepoUrl(source.url,s.selected);
  }
  for(const key of ['commits','pulls','runs','checks','tests','branches','director']) {
    const source=s.sources.find(x=>x.key===key);
    if(s[key].length && !['ok','partial'].includes(source?.status)) throw new Error('Items require a successful or partial source: '+key);
    for(const item of s[key]) {
      assertRepoUrl(item.url,s.selected);
      if(item.compareUrl) assertRepoUrl(item.compareUrl,s.selected);
      for(const f of item.failures??[]) assertRepoUrl(f.url,s.selected);
    }
  }
  // Missing source evidence always remains unknown; do not derive approvals from CI.
  return {snapshot:s,...contextData,local:{connected:false},mode:'chat-mediated',version:'0.2.0'};
}
// Comparison proposes continuity; it never edits, resumes or replaces a chat.
function reconcileThreads(carried,current,proposals=[]){
  if(carried.repository.toLowerCase()!==current.repository.toLowerCase())throw new Error('Carried and current repositories differ');
  const norm=t=>(t.title??'').trim().replace(/\s+/g,' ').toLowerCase();
  const live=new Map(current.threads.map(t=>[t.id,t])),old=new Map(carried.threads.map(t=>[t.id,t]));
  const pairs=new Map(),used=new Set();
  for(const p of proposals){
    validate(p,reconciledContextSchema);
    const a=old.get(p.carriedId),b=live.get(p.currentId);
    if(!a||!b)throw new Error('Reconciled context references an unknown chat');
    if(pairs.has(a.id)||used.has(b.id))throw new Error('Reconciliation must be one to one');
    if(a.id!==b.id&&!(a.taskKey&&(a.taskKey===b.taskKey||(a.knownThreadIds??[]).includes(b.id)))&&!p.matchEvidence.trim())throw new Error('Different chat IDs require explicit user match evidence');
    if(!['read','partial'].includes(a.readState)||!['read','partial'].includes(b.readState))throw new Error('Unread chats cannot have reconciled context');
    if(/(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|Authorization:\s*Bearer\s+\S{12,})/.test(JSON.stringify(p)))throw new Error('Remove credentials from reconciliation');
    pairs.set(a.id,p);used.add(b.id);
  }
  for(const a of carried.threads)if(live.has(a.id)&&!pairs.has(a.id)){
    if(used.has(a.id))throw new Error('A current chat is already paired');
    pairs.set(a.id,null);used.add(a.id);
  }
  for(const a of carried.threads)if(a.taskKey&&!pairs.has(a.id)){
    const candidates=current.threads.filter(b=>!used.has(b.id)&&(b.taskKey===a.taskKey||(a.knownThreadIds??[]).includes(b.id))&&b.kind===a.kind);
    if(candidates.length===1&&carried.threads.filter(b=>b.taskKey===a.taskKey).length===1){pairs.set(a.id,{currentId:candidates[0].id,identityOnly:true});used.add(candidates[0].id);}
  }
  const remainingOld=carried.threads.filter(a=>!pairs.has(a.id)),remainingCurrent=current.threads.filter(b=>!used.has(b.id));
  const mentioned=new Set(),rows=[];
  for(const a of carried.threads){
    if(pairs.has(a.id)){
      const p=pairs.get(a.id),b=live.get(p?.currentId??a.id);
      const fields=['context','decisions','openItems','resumePoint'];
      const differences=fields.filter(k=>JSON.stringify(a[k])!==JSON.stringify(b[k]));
      rows.push({carriedId:a.id,currentIds:[b.id],match:a.id===b.id?'same_id':a.taskKey&&(a.taskKey===b.taskKey||(a.knownThreadIds??[]).includes(b.id))?'same_task':'user_confirmed',differences,progress:a.progressUid&&b.progressUid?(a.progressUid===b.progressUid?'same':'different'):'unknown',proposal:p?.identityOnly?null:p});continue;
    }
    const candidates=norm(a)?remainingCurrent.filter(b=>norm(b)===norm(a)&&b.kind===a.kind):[];
    candidates.forEach(b=>mentioned.add(b.id));
    const unique=candidates.length===1&&remainingOld.filter(b=>norm(b)===norm(a)&&b.kind===a.kind).length===1;
    rows.push({carriedId:a.id,currentIds:candidates.map(b=>b.id),match:unique?'title_candidate':candidates.length?'ambiguous':'carried_only',differences:[],proposal:null});
  }
  for(const b of remainingCurrent)if(!mentioned.has(b.id))rows.push({carriedId:null,currentIds:[b.id],match:'current_only',differences:[],proposal:null});
  return {rows,coverage:current.discovery==='complete'?'complete':'partial',message:'Read-only comparison. Missing here does not mean deleted or completed. Title matches need user confirmation. Reconciled context is a proposal; both source summaries and their coverage remain available.'};
}
function makeContextPacket(context,now=new Date()){
  return {format:'cory-context-v1',exportedAt:now.toISOString(),threadContext:normalizeThreadContext(context,null,now)};
}
function readContextPacket(packet,repository=null,now=new Date()){
  validate(packet,object({format:choice(['cory-context-v1','cory-context-v2']),exportedAt:date,threadContext:threadContextSchema,departmentContext:departmentContextSchema},['format','exportedAt','threadContext']));
  if(packet.format==='cory-context-v2'&&!packet.departmentContext)throw new Error('Department checkpoint is missing its records');
  if(packet.departmentContext)normalizeDepartmentContext(packet.departmentContext,repository,now);
  if(Date.parse(packet.exportedAt)>now.getTime()+60000)throw new Error('Packet timestamp is in the future');
  return normalizeThreadContext(packet.threadContext,repository,now);
}
function normalizeDepartmentContext(value,repository=null,now=new Date()){
  validate(value,departmentContextSchema);
  if(repository&&value.repository.toLowerCase()!==repository.toLowerCase())throw new Error('Departments belong to another repository');
  if(Date.parse(value.observedAt)>now.getTime()+60000)throw new Error('Department timestamp is in the future');
  if(new Set(value.records.map(r=>r.key)).size!==value.records.length)throw new Error('Duplicate departments');
  for(const r of value.records){
    if(!/^docs\/(?:departments|checkpoints\/[A-Za-z0-9_-]+\/departments)\/[a-z_]+\.md$/.test(r.sourceFile)||!r.sourceFile.endsWith('/'+r.key+'.md'))throw new Error('Invalid department record path');
    if(/(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|Authorization:\s*Bearer\s+\S{12,})/.test(r.markdown))throw new Error('Remove credentials from department records');
  }
  return structuredClone(value);
}
function normalizeCheckpointReview(value,repository=null,now=new Date()){
  validate(value,checkpointReviewSchema);
  if(repository&&value.repository.toLowerCase()!==repository.toLowerCase())throw new Error('Checkpoint review belongs to another repository');
  if(Date.parse(value.observedAt)>now.getTime()+60000)throw new Error('Checkpoint review timestamp is in the future');
  for(const file of value.paths)if(!file||/^(?:[\\/]|[A-Za-z]:)/.test(file)||/[\0\r\n]/.test(file)||file.split(/[\\/]/).some(p=>p==='..'||p==='.git'))throw new Error('Review paths must stay within the selected repository');
  if(value.state==='ready'&&(!value.localHead||!value.depotHead))throw new Error('A ready review needs verified local and depot revisions');
  if(value.action==='save'&&value.state==='ready'&&(!value.paths.length||!value.workingDigest))throw new Error('A ready save needs exact candidate paths and their content digest');
  return structuredClone(value);
}
function normalizeThreadContext(context,selected,now=new Date()) {
  validate(context,threadContextSchema,'$.threadContext');
  if(selected && context.repository.toLowerCase()!==selected.toLowerCase())throw new Error('Chat context must belong to the selected repository');
  if(Date.parse(context.observedAt)>now.getTime()+60000)throw new Error('Chat context timestamp is in the future');
  if(new Set(context.threads.map(t=>t.id)).size!==context.threads.length)throw new Error('Duplicate chat context');
  if(context.discoveredCount<context.threads.length)throw new Error('Chat discovery count is inconsistent');
  if(context.discovery==='complete' && context.discoveredCount!==context.threads.length)throw new Error('Complete discovery must account for every discovered chat');
  for(const t of context.threads){
    if(t.membership==='project_id' && t.projectId!==context.projectId)throw new Error('Chat belongs to a different project');
    if(t.projectId!==null && t.projectId!==context.projectId)throw new Error('Chat project identity does not match');
    if(Date.parse(t.observedAt)>now.getTime()+60000)throw new Error('Chat read timestamp is in the future');
    if(t.hasOlder===true && t.readState==='read')throw new Error('Unread older history must remain partial');
    if(['unavailable','error'].includes(t.readState) && (t.context||t.decisions.length||t.openItems.length||t.resumePoint))throw new Error('Failed chat reads cannot supply context');
    const content=[t.title??'',t.context,...t.decisions,...t.openItems,t.resumePoint].join('\n');
    if(/(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|Authorization:\s*Bearer\s+\S{12,})/.test(content))throw new Error('Remove credentials before supplying chat context');
  }
  return structuredClone(context);
}
function assertRepoUrl(value,fullName) {
  const u=new URL(value);
  const prefix=(u.hostname==='api.github.com'?'/repos/':'/')+fullName;
  const path=u.pathname.toLowerCase();
  if(!fullName || (path!==prefix.toLowerCase() && !path.startsWith(prefix.toLowerCase()+'/'))) throw new Error('Link must belong to its selected repository');
}


function checkpointContext(manifest,readNote,repository,now=new Date()){
  if(![3,4].includes(manifest.schema_version)||!Array.isArray(manifest.tasks)||!manifest.tasks.length)throw new Error('Schema 3 or 4 checkpoint notes are required');
  if(manifest.schema_version===4)assertTaskDepartments(manifest.tasks);
  if(new Set(manifest.tasks.map(t=>t.task_key)).size!==manifest.tasks.length)throw new Error('Duplicate checkpoint task keys');
  const section=(note,title)=>note.match(new RegExp('^## '+title+'\\s*\\n([\\s\\S]*?)(?=^## |$(?![\\s\\S]))','m'))?.[1]?.trim()??'';
  const clean=s=>String(s).replace(/[A-Za-z]:[\\/](?:Users|Documents)[^\n)]*/g,'[local path omitted]').trim();
  const threads=manifest.tasks.map(t=>{
    if(!t.task_key||!t.task_file||!t.canonical_title||!Array.isArray(t.aliases))throw new Error('Checkpoint task identity is incomplete');
    const note=readNote(t.task_file),carried=clean(section(note,'Carried context')),resume=clean(section(note,'Resume point'));
    if(!carried||!resume)throw new Error('Checkpoint note lacks carried context or resume point');
    const binding=t.binding??{},ids=[binding.thread_id,...(t.binding_history??[]).map(b=>b.thread_id)].filter(Boolean);
    return {id:binding.thread_id??'task-'+t.task_key,title:t.canonical_title,kind:'codex',hostId:null,projectId:manifest.project_id,membership:'project_id',activity:'checkpoint snapshot',updatedAt:binding.latest_completed_at?new Date(binding.latest_completed_at*1000).toISOString():null,observedAt:now.toISOString(),readState:'partial',context:clean([t.summary,carried].filter(Boolean).join('\n')).slice(0,2000),decisions:[],openItems:[],resumePoint:resume.slice(0,1000),coverage:'Checkpoint '+manifest.checkpoint_id+' development notes only; text may be abridged. Source chat history was not read by this helper.',turnsRead:0,hasOlder:null,taskKey:t.task_key,aliases:t.aliases,progressUid:t.progress_uid??null,knownThreadIds:[...new Set(ids)],departmentKey:t.department_key??null};
  });
  const packet=makeContextPacket(normalizeThreadContext({repository,projectId:manifest.project_id,projectName:'Laema',scope:'all_unarchived',observedAt:now.toISOString(),discovery:'partial',discoveredCount:threads.length,message:'Carried checkpoint '+manifest.checkpoint_id+'. This is the saved task set, not a fresh local discovery. Development summaries only; current chats must be read separately.',threads},repository,now),now);
  if(manifest.schema_version===4){
    if(!Array.isArray(manifest.departments)||manifest.departments.length!==departmentKeys.length||new Set(manifest.departments.map(d=>d.department_key)).size!==departmentKeys.length)throw new Error('Save all eight persistent departments');
    packet.format='cory-context-v2';
    packet.departmentContext=normalizeDepartmentContext({repository,observedAt:now.toISOString(),records:manifest.departments.map(d=>{
      if(!departmentKeys.includes(d.department_key)||d.department_file!=='departments/'+d.department_key+'.md')throw new Error('Invalid checkpoint department path');
      return {key:d.department_key,markdown:readNote(d.department_file),sourceFile:'docs/checkpoints/'+manifest.checkpoint_id+'/'+d.department_file,source:'checkpoint',coverage:'Saved department context; source conversations may have partial coverage.',uid:manifest.department_context_uids?.[d.department_key]??null};
    })},repository,now);
  }
  return packet;
}
function assertTaskDepartments(tasks){
  const missing=tasks.filter(t=>!departmentKeys.includes(t.department_key)&&!(t.task_key==='production_manager'&&t.position_key==='production_manager'&&t.department_key==null));
  if(missing.length)throw new Error('Choose a department or Other for: '+missing.map(t=>t.canonical_title??t.task_key).join(', '));
}
function bindCheckpointIdentities(current,carried){
  // Only a saved binding ID assigns identity. Similar titles remain candidates.
  const result=structuredClone(current);
  for(const t of result.threads){const matches=carried.threads.filter(a=>a.id===t.id||(a.knownThreadIds??[]).includes(t.id));if(matches.length===1){t.taskKey=matches[0].taskKey;t.aliases=matches[0].aliases;t.knownThreadIds=matches[0].knownThreadIds;}}
  return result;
}

import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';

export function runCheckpointContext(args){
  const [mode,rootArg,manifestArg]=args;
  if(!['--write','--read','--read-departments','--review'].includes(mode)||!rootArg||args.length>3)throw new Error('Use --write, --read, --read-departments or --review with project root');
  const root=fs.realpathSync(rootArg),checkpoints=fs.realpathSync(path.join(root,'docs/checkpoints'));
  if(!checkpoints.startsWith(root+path.sep))throw new Error('Checkpoint directory escaped its project');
  const read=(file,limit)=>{if(fs.statSync(file).size>limit)throw new Error('Checkpoint file exceeds its size bound');return fs.readFileSync(file,'utf8');};
  const git=argv=>{const r=spawnSync('git',['-C',root,...argv],{encoding:'utf8',windowsHide:true});if(r.status!==0)throw new Error('Checkpoint Git metadata unavailable');return r.stdout.trim();};
  const remote=git(['remote','get-url','origin']),repository=remote.match(/github\.com[:/]([^/]+\/[^/]+?)(?:\.git)?$/)?.[1];
  if(!repository)throw new Error('Confirm the GitHub depot before reading or saving Cory context');
  if(mode==='--review'){
    const run=argv=>spawnSync('git',['-C',root,...argv],{encoding:'utf8',windowsHide:true});
    const changed=git(['diff','--name-only','-z','HEAD']).split('\0').filter(Boolean),untracked=git(['ls-files','--others','--exclude-standard','-z']).split('\0').filter(Boolean);
    const paths=[...new Set([...changed,...untracked])].sort(),digest=createHash('sha256');
    for(const relative of paths){
      if(path.isAbsolute(relative)||relative.split(/[\\/]/).some(p=>p==='..'||p==='.git'))throw new Error('Unsafe review path');
      const full=path.join(root,relative);digest.update(relative+'\0');
      const stat=fs.lstatSync(full,{throwIfNoEntry:false});if(!stat){digest.update('deleted\0');continue;}
      if(stat.isSymbolicLink()){digest.update('symlink\0'+fs.readlinkSync(full)+'\0');continue;}
      if(!stat.isFile()||!fs.realpathSync(full).startsWith(root+path.sep))throw new Error('Review files must remain in the repository');
      digest.update('file\0'+stat.size+'\0');const fd=fs.openSync(full,'r');try{const buffer=Buffer.alloc(65536);let count;while((count=fs.readSync(fd,buffer,0,buffer.length,null)))digest.update(buffer.subarray(0,count));}finally{fs.closeSync(fd);}digest.update('\0');
    }
    const local=run(['rev-parse','HEAD']),depot=run(['rev-parse','refs/remotes/origin/main']);
    return {repository,observedAt:new Date().toISOString(),paths,workingDigest:digest.digest('hex'),localHead:local.status===0?local.stdout.trim():null,trackedDepotHead:depot.status===0?depot.stdout.trim():null,coverage:'Local candidate files only. No staging, network, commit or push. Independently verify the current depot HEAD before a ready review.'};
  }
  const departmentRoot=path.join(root,'docs/departments'),registryPath=path.join(departmentRoot,'task-departments.json');
  const readDepartments=()=>{
    const folder=fs.realpathSync(departmentRoot);if(!folder.startsWith(root+path.sep))throw new Error('Department folder escaped its project');
    return normalizeDepartmentContext({repository,observedAt:new Date().toISOString(),records:departmentKeys.map(key=>{
      const file=fs.realpathSync(path.join(folder,key+'.md'));if(!file.startsWith(folder+path.sep))throw new Error('Department record escaped its folder');
      const markdown=read(file,16000);return {key,markdown,sourceFile:'docs/departments/'+key+'.md',source:'local_unpublished',coverage:'Working department record; not assumed published until a checkpoint push.',uid:createHash('sha256').update(markdown).digest('hex')};
    })},repository);
  };
  const readRegistry=()=>{
    const full=fs.realpathSync(registryPath);if(!full.startsWith(fs.realpathSync(departmentRoot)+path.sep))throw new Error('Task registry escaped its folder');
    const value=JSON.parse(read(full,256*1024));
    if(value.repository!==repository||!Array.isArray(value.tasks)||new Set(value.tasks.map(t=>t.task_key)).size!==value.tasks.length)throw new Error('Invalid department task registry');
    for(const t of value.tasks)if(!t.task_key||(t.department_key!==null&&!departmentKeys.includes(t.department_key)))throw new Error('Invalid task department');
    return value;
  };
  if(mode==='--read-departments')return {departmentContext:readDepartments(),assignments:readRegistry().tasks};
  const safe=relative=>{
    if(path.isAbsolute(relative)||relative.split(/[\\/]/).includes('..'))throw new Error('Checkpoint path must be repository relative');
    const full=fs.realpathSync(path.join(root,relative));
    if(!full.startsWith(checkpoints+path.sep))throw new Error('Checkpoint path escaped its directory');return full;
  };
  let manifestPath=manifestArg;
  const pointer=path.join(checkpoints,'latest.json');
  if(!manifestPath){
    if(fs.existsSync(pointer))manifestPath=JSON.parse(read(safe('docs/checkpoints/latest.json'),16384)).manifest;
    else {const paths=git(['log','-1','--format=','--name-only','--','docs/checkpoints/**/manifest.json']).split(/\r?\n/).filter(s=>s.endsWith('/manifest.json')).sort();if(paths.length!==1)throw new Error('Latest checkpoint is ambiguous; supply its manifest explicitly');manifestPath=paths[0];}
  }
  const full=safe(manifestPath),manifest=JSON.parse(read(full,256*1024)),dir=path.dirname(full),snapshotFile=path.join(dir,'cory-context.json');
  const relative=p=>path.relative(root,p).replaceAll('\\','/');
  if(mode==='--read'&&fs.existsSync(snapshotFile)){const packet=JSON.parse(read(safe(relative(snapshotFile)),2*1024*1024));const context=readContextPacket(packet,repository);if(context.projectId!==manifest.project_id)throw new Error('Snapshot does not identify its checkpoint project');return {manifest:relative(full),checkpointId:manifest.checkpoint_id,packet:{...packet,threadContext:context}};}
  let departmentContext=null,registry=null;
  if(mode==='--write'&&manifest.schema_version===4){
    assertTaskDepartments(manifest.tasks);departmentContext=readDepartments();registry=readRegistry();
    for(const t of manifest.tasks){const old=registry.tasks.find(a=>a.task_key===t.task_key);if(old?.department_key!==t.department_key&&!t.department_assignment_evidence?.trim())throw new Error('Confirm department assignment for '+t.canonical_title);}
    manifest.departments=departmentKeys.map(key=>({department_key:key,department_file:'departments/'+key+'.md'}));
    manifest.department_context_uids=Object.fromEntries(departmentContext.records.map(r=>[r.key,r.uid]));
  }
  const packet=checkpointContext(manifest,taskFile=>{
    if(path.isAbsolute(taskFile)||taskFile.split(/[\\/]/).includes('..'))throw new Error('Unsafe task note path');
    if(departmentContext&&taskFile.startsWith('departments/'))return departmentContext.records.find(r=>'departments/'+r.key+'.md'===taskFile)?.markdown??'';
    const note=fs.realpathSync(path.join(dir,taskFile));if(!note.startsWith(dir+path.sep))throw new Error('Task note escaped its checkpoint');return read(note,16384);
  },repository);
  if(mode==='--write'){
    if(fs.existsSync(snapshotFile)&&fs.lstatSync(snapshotFile).isSymbolicLink())throw new Error('Snapshot must not be a symlink');
    if(fs.existsSync(pointer)&&fs.lstatSync(pointer).isSymbolicLink())throw new Error('Latest pointer must not be a symlink');
    if(departmentContext){
      const frozen=path.join(dir,'departments');fs.mkdirSync(frozen,{recursive:true});if(fs.realpathSync(frozen)!==frozen)throw new Error('Checkpoint department folder must not be a symlink');
      for(const r of departmentContext.records){const file=path.join(frozen,r.key+'.md');if(fs.existsSync(file)&&fs.lstatSync(file).isSymbolicLink())throw new Error('Checkpoint department record must not be a symlink');fs.writeFileSync(file,r.markdown);}
      for(const t of manifest.tasks){let old=registry.tasks.find(a=>a.task_key===t.task_key);if(!old){old={task_key:t.task_key,title:t.canonical_title};registry.tasks.push(old);}if(old.department_key!==t.department_key){old.department_key=t.department_key;old.assignment_evidence=t.department_assignment_evidence;}}
      fs.writeFileSync(registryPath,JSON.stringify(registry,null,2)+'\n');fs.writeFileSync(full,JSON.stringify(manifest,null,2)+'\n');
    }
    fs.writeFileSync(snapshotFile,JSON.stringify(packet,null,2)+'\n');
    fs.writeFileSync(pointer,JSON.stringify({schema_version:1,checkpoint_id:manifest.checkpoint_id,manifest:relative(full),cory_snapshot:relative(snapshotFile)},null,2)+'\n');
    return {manifest:relative(full),checkpointId:manifest.checkpoint_id,snapshot:relative(snapshotFile),taskCount:packet.threadContext.threads.length};
  }
  return {manifest:relative(full),checkpointId:manifest.checkpoint_id,legacy:true,packet};
}
if(process.argv[1]?.endsWith('cory-checkpoint.mjs')||process.argv[1]?.endsWith('checkpoint-context-cli.mjs')){try{console.log(JSON.stringify(runCheckpointContext(process.argv.slice(2))));}catch(e){console.error(e.message);process.exitCode=1;}}
