# Fire X5 timing comparison

All rows preserve damage, Health, Impact/Poise, reaction invincibility, Heat, normalized input windows, shared Cast timing and defence/dodge rules. Numbers are candidate tuning, not human acceptance. Native X5 active/geometry markers were not changed overnight.

| Version | Windup / recovery | Base total | Observed result | Disposition |
|---|---|---|---|---|
| Preserved starting source |0.45 /0.63|1.08s|Three scripted pressure wins at100HP; endpointLv5 Casts hit during protection and added0damage.|Restorable baseline; not erased.|
| A |0.45 /0.95|1.40s|Repeated lowHeat endpoints applied13. Mixed-action encounter also won90HP. Matched0.7s cohort100/100/80HP, with first trial's354ms input stall excluded from precise timing.|Restorable comparison; superseded by provisional D.|
| B |0.45 /0.80|1.25s|Two fresh repetitions: first endpoint13, next two0; left-facing continuation also had0endpoints.|Rejected; insufficient margin as Heat/spacing changed.|
| C |0.60 /0.95|1.55s|Three matched clean0.7s wins100/90/90HP. No clear mechanical gain; firstLv5 release-to-launch960–978ms vsA827–844ms.|Inconclusive benefit; restore only its windup change.|
| D |0.45 /1.10|1.55s|On current Might f43, three matched0.7s wins80/90/80HP;7/7 valid high-level Cast contacts APPLIED13. First release-to-launch~0.960s.|Retained provisional candidate; human waiting-time/feel acceptance pending.|

These small cohorts include normal AI-wait/opener variation, not identical seeded trials. Do not infer difficulty, statistical superiority or human usability. Actual captures confirm C's windup consumer changed native speed1.333->1.0 at zeroHeat; its file edit was not hidden by an override.

## Fresh original-timing replay with current support

At03:19-03:28HKT, originalX5recovery0.63 was restored only in a closed-process isolated copy. CurrentMagicreleasefix/HUDemptyrings/cue2/helper1547 remained identical. Three fresh0.7sheld-Charging encounters won90/100/100HP with50inputedgesmax16/17/17ms and noexternalinputs. All8highlevelImpact1Cast contacts were INVINCIBLE/0Healthloss; an interrupted run's normalLv4Cast usedImpact40, and another run's late thirdrelease became normalLv5atnewchainposition1. Do not call every release an endpoint.

RootA0.95 was never overwritten. After closure, it was copied back into a fresh process with the same support for matching replay. The first A trial's firstCast applied13 versus original's0; actual capturedEnemyHealth137vs150 supports that narrow comparison. Cohort completion remains inPROGRESS.md.

The heldCharging condition matters: currentapprovedpressure rules preserve a chain beyond an action's end. These trials do not independently prove unpreserved melee-only cadence or human trigger precision. Their contact/protection comparison remains valid.

## Same-Might final A/D comparison

After the one-line preserved-gap movement-lock repair, a fresh A cohort won80/70/90HP;7valid high-level Cast contacts resolved6APPLIED/1INVINCIBLE. Fresh D changed only recovery0.95->1.10 and won80/90/80HP;7/7 contacts APPLIED13. A first release-to-launch~0.831s versus D~0.960s. D therefore adds~0.13s real queue waiting in that opening. Small unseeded cohorts do not demonstrate statistical survival superiority or human satisfaction. Natural new-charge-press-during-hurt failures occurred once in A and twice in D; neither tuning repairs that input/feedback seam.

## Important limit

A/D help the recorded lowHeat endpoint interaction but do not settle highHeat Pikeman protection. The earlier A short-flight source estimate showed contact-to-impact risk against fixed1.15s protection atHeat80/100; contact pose/spacing matter, and that estimate is not a measured D result. Genuine pure-Fire static-target practice was separately established on both same-Might A and final D:48normalLv1Casts each builtHeat4->100 without state injection. Only X3 physically reached the legacy short target; neither run is Stage7 completion or highHeat/Pikeman protection clearance. See motion-gap-fix-01/, final-d-practice-01/ and the versioned progress entries.

The longer recovery also increases release-to-spell waiting. Do not sell A as an unconditional game-feel win: the human must judge that trade-off. Bigger changes to invincibility, Cast Impact/damage or feedback semantics remain morning design work under the locked contract.
