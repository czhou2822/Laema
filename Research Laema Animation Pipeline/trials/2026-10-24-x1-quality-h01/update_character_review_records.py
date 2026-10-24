"""Carry the user's review-mode instructions forward; never modify their notes."""
from pathlib import Path
import json,hashlib,datetime
ROOT=Path(__file__).resolve().parent;RESEARCH=ROOT.parents[1];REPO=RESEARCH.parent
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
summary=('Current review direction,24 October: the user requested **Current game / v08 / H01** side by side as character-only source flipbooks, direct annotations, and clear edited-frame targets. '
 'The [same viewer](trials/2026-10-23-v08-game-integration/review.html?experiment=H01) now defaults to that mode. '
 'Use the5/6/7 buttons; these are trial sprite drawing numbers, especially7, not recorded gameplay-frame counters. '
 'Read active entries in [annotations.json](trials/2026-10-24-x1-quality-h01/annotations.json) before further art work; retain their version SHA, frame range, point, Heat and facing. '
 'Removed validation notes/history are not artistic feedback. Notes are observations, not automatic artwork/gameplay approval. '
 'Scene recordings remain separate integration evidence, not the main animation review. Start the viewer with **python "Research Laema Animation Pipeline/review_server.py"** from the repository root so note saving works. '
 'No sprite artwork or gameplay changed in this UI update; the artistic verdict remains pending.')
for filename in ['CONTINUE_LOCAL.md','FINDINGS.md']:
 path=RESEARCH/filename;text=path.read_text(encoding='utf-8')
 if summary not in text:
  first,rest=text.split('\n',1);path.write_text(first+'\n\n'+summary+'\n'+rest,encoding='utf-8',newline='\n')
path=RESEARCH/'README.md';text=path.read_text(encoding='utf-8');parts=text.split('\n\n')
i=next(i for i,p in enumerate(parts) if p.startswith('**Local status:'))
parts[i]='**Local status: character-only three-version review and direct annotations are ready; H01 has no accepted artistic verdict.** '+summary
path.write_text('\n\n'.join(parts),encoding='utf-8',newline='\n')
path=ROOT/'README.md';text=path.read_text(encoding='utf-8')
old=next((p for p in text.split('\n\n') if p.startswith('Open [v08 versus H01')),None)
new=('Open [the three-character comparison](../2026-10-23-v08-game-integration/review.html?experiment=H01): **Current game / v08 previous / H01 this iteration**. '
     'It plays the actual source sprite sheets at their saved action times, on a neutral background with a common foot anchor. No scene, enemy, HUD, camera, hit-stop or root lunge is included in this art review. '
     'Normal size is1× gameplay sprite scale. Pause/scrub, frame stepping, Heat0/100, facing, inspection zoom, shared pan, edited-region outlines and version-specific annotations are available. '
     'The [H01 integration recordings](../2026-10-23-v08-game-integration/review.html?experiment=H01&view=recording) and '
     '[original-game/v08 recordings](../2026-10-23-v08-game-integration/review.html?view=recording) remain optional technical checks. '
     'The [playable copied project](gameplay-preview/project.godot) is unchanged.')
if old:text=text.replace(old,new,1)
addition='''
## Which frames to review

These frame numbers apply to **v08 and H01**. The current game has8 keys, while both trials have16; compare equal action times rather than equal frame numbers across all three.

| Trial frame | Heat0 interval | Focus |
| --- | --- | --- |
| 5 |0.126–0.142s| Fingers enclosing the upright hilt |
| 6 |0.142–0.158s| Grip connection while the blade rotates |
| **7** |**0.158–0.184s**| **Forearm → wrist → palm → hilt connection** |

The5/6/7 buttons pause all versions at the matching source time. At trial frame7 the current game shows frame4/8. H01 changes local arm/grip pixels in these three keys; the other13 trial cells, all key times, protected sword regions and surrounding body remain unchanged. This does not correct body weight transfer or braking.

## Annotating directly

Click a character to place a point and open a note, or choose **Note this frame**. The editor captures the version, sprite SHA and frame; it stays anchored when the timeline moves. **From frame / Through frame** supports a range. Save persists the observation in [annotations.json](annotations.json), with Heat/facing and optional native-cell point coordinates. Notes can be shown, edited, softly removed/restored and exported. Unsaved drafts have a browser-local backup; saved notes live in the research folder. Prior saved state is backed up and edit/removal history is retained. No note is automatically promoted into an accepted art/gameplay decision.

Run `python "Research Laema Animation Pipeline/review_server.py"` from the repository root; a generic static HTTP server cannot save notes. Continue from active, nondeleted notes in the main annotations file, not its backup. The clearly marked UI validation note is removed and is not artistic feedback. Eight isolated storage checks and a live save/reload/remove check were performed; user-authored feedback was not replaced.

The user's correction supersedes the earlier emphasis on gameplay captures for artistic review. Source flipbooks are the default now; scene recording is reserved for integration questions. This viewer update generates no new art and establishes no quality improvement by itself.
'''
if '## Which frames to review' not in text:text=text.replace('\n## Question and controls',addition+'\n## Question and controls',1)
path.write_text(text,encoding='utf-8',newline='\n')
path=RESEARCH/'QUALITY_WORKFLOW.md';text=path.read_text(encoding='utf-8')
old='Review order: full swing at native gameplay size/normal speed; the corresponding key poses and silhouettes; slow/stepped playback for diagnosis; actual-game context and return/interruptions.'
new='Review order: character-only source flipbooks at native gameplay size/normal speed; the corresponding key poses and silhouettes; slow/stepped playback for diagnosis. Use actual-game context/return/interruptions as a separate integration check, rather than recording the scene for every artistic iteration.'
text=text.replace(old,new)
if 'Direct review notes:' not in text:text+='\nDirect review notes: use the comparison tool to pin observations to a version SHA and source drawing/range. Read active annotations before the next experiment. Preserve removed-note history, but do not treat validation/deleted records or a local improvement note as broad artistic acceptance.\n'
path.write_text(text,encoding='utf-8',newline='\n')
path=ROOT/'experiment.json';exp=json.loads(path.read_text(encoding='utf-8'))
exp['review_interface']={'updated_at_utc':now,'primary_mode':'character_only_source_flipbooks','versions':['Current game','v08 previous','H01 this iteration'],
 'focus_trial_frames':[5,6,7],'main_focus_frame':7,'annotation_file':'annotations.json','annotation_binding':['version_id','sprite_sha256','from_frame','through_frame','Heat','facing','optional native-cell point'],
 'integration_recordings':'retained separately; no new scene recording required for this UI update','user_artistic_verdict':'pending',
 'reason':'User requested a simple three-character comparison and direct frame-specific notes; gameplay-scene captures obscured the animation review.'}
path.write_text(json.dumps(exp,indent=2)+'\n',encoding='utf-8',newline='\n')
path=RESEARCH/'evidence/round-record.json';record=json.loads(path.read_text())
record.update(updated_at_utc=now,primary_review_mode='character_only_three_versions',annotation_file='trials/2026-10-24-x1-quality-h01/annotations.json',
 awaiting_user='Review the three source flipbooks, especially v08/H01 frames5–7, and annotate directly. No artistic verdict has been supplied.')
path.write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
path=REPO/'docs/departments/combat.md';text=path.read_text(encoding='utf-8')
entry=('\n- Animation review clarification,24 October: user wants current game/v08/H01 as character-only source flipbooks with direct frame/range annotations. '
 'The viewer now defaults to that comparison; source-timed frames5–7 are the focus, especially7. Saved annotations retain sprite SHA/version/frame/pin/Heat/facing; active annotations are the feedback source, not removed validation entries. '
 'Gameplay recordings are retained for integration checks, not primary art review. No sprite/gameplay change or artistic acceptance results from this interface update. '
 'Source: Research Laema Animation Pipeline/trials/2026-10-24-x1-quality-h01/README.md.\n')
if entry not in text:path.write_text(text.replace('\n## Resume point',entry+'\n## Resume point',1),encoding='utf-8',newline='\n')
qa={'at_utc':now,'mode':'character-only; source timings, common foot registration','checked':['Three source versions load with8/16/16 drawing keys','Frame7 jump gives game4/8 and v08/H01 7/16 at0.158s','Live note saved as H01 frame7, survived a page reload, and was softly removed as validation-only','Click on canvas creates a native-coordinate pin','Scrubbing to frame10 does not move the draft anchored at frame7','Range editor can select frames5–7','Horizontal scroll at2× produces matching x/y positions in all three panels','Heat100 displays0.105/0.480s at source frame7 and facing can mirror left'],
 'separate_storage_checks':'evidence/annotation-store-verification.json','quality_verdict':None,'gameplay_or_artwork_modified':False}
(ROOT/'evidence/character-review-verification.json').write_text(json.dumps(qa,indent=2)+'\n',encoding='utf-8')
files=[]
for p in sorted(ROOT.rglob('*')):
 if p.is_file() and not set(p.parts)&{'.godot','__pycache__','captures','gameplay-preview'} and p.name not in ['artifact-manifest.json','annotations.json','annotations.backup.json']:
  files.append({'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(ROOT/'artifact-manifest.json').write_text(json.dumps({'files':files,'mutable_annotations':['annotations.json','annotations.backup.json'],'exclusions':'User notes are mutable and remain preserved; game copy/raw captures have separate inventories.'},indent=2)+'\n',encoding='utf-8')
print('Character-only review and annotation instructions reconciled; user notes were not edited.')
