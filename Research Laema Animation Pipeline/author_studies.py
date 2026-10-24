"""Original motion blocking, authored from joint targets; no source animation input."""
import json
import math
from pathlib import Path

ROOT = Path(__file__).parent

def elbow(shoulder, hand):
    dx, dy = hand[0]-shoulder[0], hand[1]-shoulder[1]
    d = max(1, math.hypot(dx, dy))
    h = math.sqrt(max(0, 34**2-(d/2)**2))
    return [(shoulder[0]+hand[0])/2-dy/d*h, (shoulder[1]+hand[1])/2+dx/d*h]

def pose(t, lean=0, sink=0, hand=(34,-126), angle=-42, shield=(5,-120), hip_x=0, mode="smooth"):
    shoulder = (lean, -139+sink)
    tip = (hand[0]+88*math.cos(math.radians(angle)), hand[1]+88*math.sin(math.radians(angle)))
    pts = {
        "hip": [hip_x,-88+sink], "neck": [lean,-145+sink],
        "head": [lean+4,-164+sink], "shoulder": shoulder,
        "elbow": elbow(shoulder,hand), "hand": hand,
        "knee_a": [-25+hip_x*.25,-43+sink*.4], "ankle_a": [-30,0],
        "knee_b": [29+hip_x*.25,-44+sink*.4], "ankle_b": [32,0],
        "shield": shield, "sword_tip": tip,
    }
    return {"t":t,"mode":mode,"points":{k:[round(n,3) for n in v] for k,v in pts.items()}}

guard = dict(hand=(34,-126),angle=-42,shield=(5,-120))
data = {
 "schema_version":1,
 "status":"MOTION_REVIEW_ONLY",
 "source_revision":"16b4c3b7199589439a276881eca7516cc0f7401c",
 "provenance":"Joint targets and timings authored for this experiment; no pre-existing animation was traced, retargeted or used to generate these poses.",
 "contract":{"move":"fire_x1","base_duration":.72,"heat100_duration":.48,"active_start":.126,"timing_split":.21,"active_end":.5075,"body_height":180,"sword_length":88,"geometry_status":"Not adapted: proposals are motion blocking, not contact-aligned replacements.","lunge_status":"Existing 3-world-pixel lunge is shown only as an optional presentation reference; not new gameplay."},
 "proposals":[
  {"id":"A","title":"Diagonal cut","description":"Rear-foot load, forward diagonal release, low braking arc.",
   "notes":"Load through hip and shoulder; keep the shield near the chest. Candidate blade emphasis .158-.210s. Follow-through is low and forward; settle back to the common guard. No new timing or hit rule.",
   "keys":[pose(0,**guard),
    pose(.050,lean=-6,sink=3,hip_x=-4,hand=(5,-153),angle=-112,shield=(2,-121)),
    pose(.100,lean=-10,sink=6,hip_x=-7,hand=(-15,-152),angle=-126,shield=(-1,-119)),
    pose(.126,lean=-5,sink=7,hip_x=-3,hand=(6,-153),angle=-82,shield=(3,-119),mode="linear"),
    pose(.158,lean=9,sink=8,hip_x=5,hand=(43,-126),angle=-18,shield=(9,-122),mode="linear"),
    pose(.210,lean=14,sink=12,hip_x=9,hand=(44,-106),angle=38,shield=(13,-119)),
    pose(.340,lean=8,sink=10,hip_x=5,hand=(28,-104),angle=85,shield=(10,-119)),
    pose(.5075,lean=2,sink=5,hip_x=1,hand=(34,-115),angle=9,shield=(6,-120)),
    pose(.620,lean=0,sink=1,hand=(34,-123),angle=-33,shield=(5,-120)),
    pose(.720,**guard)]},
  {"id":"B","title":"Level backhand","description":"Closed shoulder coil, level sweep, compact elbow brake.",
   "notes":"Torso rotation is suggested by shoulder/hip counter-shift. Candidate blade emphasis .151-.210s. Keep low vertical travel and arrest the hand before returning to common guard. Side-view rotation is approximate in this blocking rig.",
   "keys":[pose(0,**guard),
    pose(.050,lean=-5,sink=2,hip_x=3,hand=(-6,-130),angle=-112,shield=(11,-123)),
    pose(.100,lean=-11,sink=4,hip_x=5,hand=(-31,-130),angle=-172,shield=(13,-122)),
    pose(.126,lean=-6,sink=5,hip_x=4,hand=(-8,-128),angle=-135,shield=(16,-124),mode="linear"),
    pose(.151,lean=4,sink=5,hip_x=1,hand=(25,-126),angle=-65,shield=(9,-123),mode="linear"),
    pose(.190,lean=10,sink=6,hip_x=-2,hand=(47,-124),angle=-2,shield=(5,-123),mode="linear"),
    pose(.235,lean=9,sink=7,hip_x=-2,hand=(43,-118),angle=40,shield=(4,-122)),
    pose(.340,lean=4,sink=4,hip_x=0,hand=(26,-116),angle=65,shield=(5,-120)),
    pose(.5075,lean=0,sink=2,hand=(33,-121),angle=-7,shield=(5,-120)),
    pose(.620,lean=0,sink=0,hand=(34,-125),angle=-35,shield=(5,-120)),
    pose(.720,**guard)]},
  {"id":"C","title":"Rising cut","description":"Small compression, upward diagonal release, high catch and settle.",
   "notes":"Different silhouette and upward path. Candidate blade emphasis .162-.210s. Shoulder rises after the release and the blade is caught high; the recovery lowers it into the common guard. Requires separate contact-geometry review if selected.",
   "keys":[pose(0,**guard),
    pose(.050,lean=-3,sink=6,hip_x=-3,hand=(17,-110),angle=15,shield=(2,-120)),
    pose(.100,lean=-8,sink=15,hip_x=-5,hand=(0,-103),angle=138,shield=(0,-116)),
    pose(.126,lean=-5,sink=15,hip_x=-2,hand=(8,-107),angle=105,shield=(2,-119),mode="linear"),
    pose(.162,lean=5,sink=8,hip_x=3,hand=(37,-124),angle=3,shield=(7,-122),mode="linear"),
    pose(.210,lean=8,sink=-1,hip_x=4,hand=(34,-150),angle=-52,shield=(9,-125)),
    pose(.310,lean=5,sink=-2,hip_x=2,hand=(17,-165),angle=-83,shield=(7,-125)),
    pose(.440,lean=1,sink=1,hand=(22,-151),angle=-66,shield=(5,-123)),
    pose(.5075,lean=0,sink=2,hand=(29,-137),angle=-50,shield=(5,-121)),
    pose(.620,lean=0,sink=0,hand=(34,-127),angle=-43,shield=(5,-120)),
    pose(.720,**guard)]},
 ]
}
(ROOT/'study-data.json').write_text(json.dumps(data,indent=2)+'\n')
print('Wrote three original proposals, 32 keys; no source animation input.')

