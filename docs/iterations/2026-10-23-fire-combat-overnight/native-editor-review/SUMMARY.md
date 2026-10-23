# Native Player preview — limited authoring check

Godot4.7.1 opened the isolated Player scene through ordinary nativeEditorUI. Main performed selection/preview seeking only, no authoring orSave. Savedscene Gitblob stayed d41da5b79bf86eeefe1464bd39e8dc0a05a65166, matchingbaselinef6. All91non-JSONconfigresources, including nativeanimations, styles andM1settings, stayed byte-identical to the preservedbeforeSavecopy.

OriginalJPEGs are copied directly from supportedWindowscaptures without conversion/resampling:
- fire-x2-02798.jpg — reported0.2798 preview time: backwardblade/capsule nowvisiblyregistered. This is BEFORE the0.36 active marker, not evidenceofadamagingframe.
- fire-x2-064-active.jpg — actualrulerseek0.64, insideactivewindow: capsulefollowsvisibleforwardblade.
- fire-x2-080-active.jpg — actualrulerseek0.80, nearactiveend: angledblade/capsulevisiblyagree.

The initial numeric0.6entry didnotapply; actualexaminedactivevalueswere0.64/0.80. Noauthoringadjustmentwasmade to obtainalignment. EditorclosednormallyviaAltF4 withnoSaveprompt; onlyownedEditorlayout/cachechanges are expected.

Limit: threeEditorvisualsamples, notallclips/allframes/bothfacings orwhole-runtime-parity clearance. Genuinegameplaycaptures/source trace use the same nativeResources, but this doesnot replace exhaustiveauthoringchecks orhumanacceptance.

Editor startup also surfaced older dev_portal_test/gym_encounter_test scripts callingretiredAttackGeometry.contact. Thoseunusedbaselineparseerrorswere not repaired and this is NOT a cleanwhole-editor/import claim. Localstderrretainsdetails outsidepublishedsummary; no rawprivate tooloutputincluded.
