# Recorder review boundary

The game is played through its existing bound input events. The helper observes real rendered frames and published outcomes; it does not set actor positions, Health, Heat, resources, clocks or AI state. Elapsed-time macros are not human-controller usability evidence.

The original synchronous capture helper's full PNG saving cost189ms in a measured Gym frame; readback itself cost1.5ms. Dense bursts coalesced inputs by up to203ms. Those batches are excluded from precision conclusions. Warm full-encounter macros still need their recorded lateness stated; before/after conditions used the same recorder.

Candidate worker34e86c61 moves only private captured Image processing and PNG saving to one bounded thread. Scene/input/state/log access stays on the main thread; viewport readback remains synchronous. One pending frame prevents a backlog. Capture rows retain the readback frame/state; worker finish and main collection stamps are separate. Shutdown releases held input then joins the pending encoder and records it before closing logs/restoring keep-on.

Main requested an explicit strong ImageEncoder member reference until join, avoiding reliance on Callable target lifetime. Deployment and actual runtime/error/lateness evidence are pending. No thread-safety or smooth-play pass is inferred from static review alone.

## Initial worker runtime — 01:01 HKT

Deployed strong-reference helper27ceb99c in a fresh rendered Gym, ownedPID40036, outputrecorder-worker-01. Product inventory comparison checked690baseline runtime files: only FireX5style7b44b7aa and HUD59d0 differ. Startup dense-full-image batch saved all returned PNGs with error0 and no runtime stderr. Main-thread capture work measured2.2-2.8ms while the one worker encoded full/review images in205-230ms. This does not imply8full frames/sec; periods are skipped while the one job is pending.

The initial F4-hide release was106ms late in this cold batch; other initial controls were6-13ms late. Do not call that a smooth-play or precision pass. A normal Retry and warmed dense-input comparison are next. Captures are recorded with original readback stamps, which can be appended after newer input/outcome log rows; analysis must use timestamps, not assume append order is event time.

## Warm performance and shutdown — 01:05 HKT

Warm command3 repeated the earlier dense capture/action batch. All14scheduled controls registered0-16ms late, with no coalesced move press/release, no unexpected inputs, no runtime stderr and PNGerror0. That is a measured recorder improvement, not human usability or a guarantee of every future frame.

Quit arrived while the next support-only recording job was active: command4readback253ms, quit400ms, encoder joined/logged485ms, then keep-on restored and session stopped exit0. Both PNGs saved successfully. However ObjectDB/resources warnings increased to21/13 versus prior13/9; do NOT call shutdown clean. A bounded no-capture/ordinary-completion comparison is next, with U read-only lifecycle triage. No unrelated product teardown repair is authorized.

## No-job comparison — 01:08 HKT

The same helper27ceb with no captures ever requested exited0 at original13ObjectDB/9resources. Merely declaring ImageEncoder does not reproduce21/13. Encoding invocation versus stopping an active job remains to distinguish. Verbose runtime showed existing RGB8-to-RGBA8 conversion warnings; these are not newly created product behavior.

The no-job run also tested held Circle through readiness: only initial and later fresh press produced dodges, each24ticks. It does not verify analog-stick priority. Same-frame keyboardLeft+Circle followed lastfacingRight; current source prioritizes raw axis only for an actually connected joypad, and none is connected. Keep that controller seam explicit rather than simulating a controller connection or claiming it passed.

## Completed-job ordinary quit — 01:11 HKT

Same27ceb helper with completed PNG jobs, followed by a later ordinary quit, exited0 at original13/9. Verbose output listed only the9existing entity/health scripts as retained resources. The21/13 increase is specific to immediate quit after draining the active worker; it is not reproduced by ordinary completed encoding. U is concluding bounded support-lifecycle triage; primary play continues with completed-job shutdown. No unrelated teardown change or claim of globally clean shutdown.

This is test support only; no gameplay architecture, settings or normal user profile is changed. Current product candidates are FireX5 recovery0.95 and dim empty orb-slot rings. They remain pending human acceptance.

## 05:39 HKT — Completed-job workaround is not a guarantee

LaterMightrepair/longArena run59732 exited0 butshowed21ObjectDB/13resources evenwithoutpendingencoderwork. Recordedlastcapturecollection/command9finish was1,460,793ms; quit10was1,677,934ms,217.14secondslater,nosubsequentcaptures. Helpercompletionjoins/clearsworker/encoder/context thenpendingflag; commandcompletionrequirespendingfalse. BothfinalPNGerrors0; keep-onprevious/restored/reportedtruebeforestop.

Thereforetheearlierstatementthatextrawarningsarespecifictoimmediatein-flightstopwas toostrong. Ordinarycompleted-jobquitdoesnotguarantee13/9. Extraobject/resourceidentitiesandownersremainunknown; longerArenacontextdiffersfromearlierGymruns. Countsprove neitherpersistenthelperleak norproductioncause. No teardown/audio/lifecyclearchitecturepatchwasmade; preservewarningandcontinueindependentgameplayreplays. Currentcandidate/source/evidenceinventoryisinPROGRESS.md ratherthanthishistoricalrecordersection.
