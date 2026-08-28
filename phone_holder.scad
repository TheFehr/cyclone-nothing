// Phone holder arm for a GameSir Cyclone-family controller + Nothing Phone 2.
//
// Layout: [connector, bulked for strength, USB-C slot left open] --diagonal
// arm (angle customizable)--> [print-in-place rotating pivot] --> [clamp
// running along the phone's LONG edge].
//
// The pivot's rotation axis is perpendicular to the phone's flat face, so
// spinning the clamp end 90 degrees swaps portrait (DS emulation) <->
// landscape (PC emulation) while the phone stays flat-facing the same way.
// It's a single printed-in-place pin+collar (no bolt/nut, no second print)
// -- print with the model rotated so Y is vertical on the bed, so the
// pin/collar layers form clean concentric circles instead of needing to
// bridge the clearance gap.
//
// Base geometry (connector_only.stl) is reverse-engineered from a
// Thingiverse remix (thing:6765266, nikopla / HaraldVI, CC BY), kept
// byte-for-byte since it has to mate with real hardware.
//
// The phone clamp is screw-adjustable, car/bike-mount claw style: a small
// hook claw at each end of a rail grips only the phone's short top/bottom
// edges -- screen and back stay fully exposed. One claw is fixed, the
// other rides a printed leadscrew (real threads, rcolyer/threads-scad,
// CC0) that runs along the phone's long axis -- no metal hardware
// anywhere in this design.

use <lib/threads.scad>

/* [Render] */

// Which piece to show/export. "full" is an assembled preview only -- the
// pivot pin/collar, the two claws, and the leadscrew are separate, unfused
// bodies (by design -- print-in-place pivot, screw-adjustable clamp), so
// it isn't watertight/printable as a single part.
render_part = "connector"; // [connector:Connector plate only — reference/preview only, base.stl already includes this, don't print separately,base:Connector + arm + pivot pin (print this),clamp_center:Rail + both bearing bosses, no collar (print this),collar_top:Pivot collar, top half — screws onto collar_bottom around the pin (print this),collar_bottom:Pivot collar, bottom half (print this),flange_nut:Screw retention flange — threads onto the screw's center, then glued (print this),clamp_claw_right:Right claw — right-hand thread (print this),clamp_claw_left:Left claw — left-hand thread (print this),screw:Dual-thread leadscrew, no flange, no knob (print this),knob:Turning knob, glues onto the screw's peg (print this),full:Full assembly (preview only)]

/* [Connector] */

// Extra material added around the connector base for strength (the USB-C
// slot is always kept clear regardless of this value)
bulk_margin = 3; // [0:0.5:8]

// How far the bulk pad extends outward before the arm begins
bulk_depth = 6; // [2:0.5:15]

/* [Arm] */

// Tilt of the arm away from straight-up, toward the phone
arm_angle = 45; // [0:1:60]

// Arm length along that diagonal -- driven by DS/portrait-mode clearance,
// not looks. Short-edge grip (claws on the phone's 162mm length, naturally
// symmetric on X) plus the now-symmetric width grip (Y) gives a worst-case
// corner at sqrt(81^2 + 38.2^2) = ~89.6mm from the axis. 110 gives ~96.4mm
// of clearance against the reinforced connector pad (verified via the
// same closest-point-to-bbox check used throughout), a margin over the
// 89.6mm minimum.
arm_length = 110; // [20:1:220]

// Cross-section at the pivot end
arm_thickness = 6; // [2:0.5:12]
arm_width = 25; // [20:0.5:30]

// Cross-section at the connector end -- thicker on purpose: this is a
// cantilever fixed at the connector and loaded at the pivot end, so
// bending stress is highest right here, not at the tip
arm_base_thickness = 10; // [4:0.5:18]
arm_base_width = 24.8; // [20:0.5:30]

// How far the gusset at each end blends into the standard arm
// cross-section before running the rest of arm_length at full thickness
arm_gusset_len = 16; // [5:1:40]

/* [Pivot] */

// Print-in-place: rotation axis runs perpendicular to the phone's face.
// Print with this axis vertical on the bed for a clean result.
pivot_shaft_dia = 6; // [4:0.5:12]
pivot_shaft_len = 30; // [16:1:60]
pivot_flange_dia = 14; // [8:0.5:24]
pivot_flange_h = 2.4; // [1.2:0.2:5]
pivot_collar_dia = 12; // [8:0.5:22]
pivot_clearance = 0.5; // [0.2:0.05:1]

// How far the collar extends PAST the shaft's far flange before the rail/
// claw assembly attaches, measured from where the flange-clearing cap
// ends. The claws need to reach all the way to the true axis line (X=0,
// Y=0) to grip the phone centered on BOTH axes -- but at the shaft's own
// depth, that exact spot is solid collar material. This pushes the
// attachment point further along the axis (further from the connector,
// "toward the user") into empty space where nothing blocks X=0,Y=0.
//
// Trimmed down from an earlier, more generous 30 once a structural check
// showed the extra rod thickness wasn't needed (bending stress from the
// phone's static weight is ~25x under typical FDM strength regardless).
// But it can't go BELOW ~20.2: at that point the rail creeps back far
// enough to overlap the FAR FLANGE's own Z-range (a separate constraint
// from the rod-length one) -- caught via the full rotation-sweep check,
// which showed a constant collision at every angle (a dead giveaway it
// was a static Z-overlap, not an actual rotational sweep problem). 24
// keeps a few mm of margin over that floor.
pivot_standoff = 24; // [21:1:60]

// Extra tilt of the pivot axis, on top of the base -90 degrees (which
// would face the clamp straight back down the arm at the controller).
// Needed for two reasons: (1) so the phone's screen faces the user
// instead of pointing down at their hands on the controller, and (2) so
// the clamp/rail clears the arm and controller body as it swings between
// DS/portrait and PC/landscape instead of crashing into them mid-rotation.
// ~135 was confirmed correct via a render sweep (0/45/90/135/180/-45)
// against where the screen should face -- re-verify with a render if the
// arm_angle or connector orientation changes materially.
pivot_tilt = 135; // [0:1:180]

/* [Clamp] */

// Total rail length, along the phone's LONG axis -- needs to cover the
// phone's height (162mm) plus adjustment travel
rail_length = 175; // [100:1:250]

// Distance from the rail's center (X=0, where the pivot attaches) to each
// claw. Both claws sit at +-claw_offset -- symmetric, so the phone stays
// centered on the pivot on the LENGTH axis at any grip width. Default
// targets a ~162mm grip span to match the Nothing Phone 2's height.
claw_offset = 81; // [20:1:85]

// Width of each claw along the rail axis
claw_width = 18; // [10:1:30]

// How far each claw's lip wraps over the phone's face, SYMMETRIC around
// the true axis (Y=-claw_reach/2 to +claw_reach/2) -- this is what lets
// the phone center on the WIDTH axis too, not just the length axis. Only
// possible because the claws attach beyond pivot_standoff, past the
// collar, where X=0,Y=0 is actually empty (at the collar's own depth no
// symmetric reach is possible -- verified via an intersection() check
// that caught a real overlap when this was tried without the standoff).
//
// Deliberately set to slightly EXCEED the 76.4mm phone width (not capped
// under it): the claw's end walls (needed to structurally bridge the top
// and bottom lips -- see claw() below) span the full thickness gap, so
// they have to land outside the phone's actual footprint or they collide
// with it edge-on. Capping claw_reach under the phone width put those
// walls INSIDE the phone's footprint instead -- caught via an actual
// intersection() check (934mm^3 of real overlap), not assumed safe.
claw_reach = 82; // [10:1:90]

// Combined thickness of phone + case at the edge each claw grips -- 10mm
// tested and confirmed to fit a Nothing Phone 2 (+ case) via a quick-check
// print; adjust and re-test if your case is different
phone_thickness = 10; // [4:0.5:20]

// Phone width (short axis, Nothing Phone 2 = 76.4mm). Not used by any
// printed geometry -- the claws grip wherever claw_reach puts them,
// anywhere along the edge is a valid grip point -- only used to place the
// phone correctly in the "full" preview so it actually sits centered on
// the pivot rather than looking like it's floating off to one side.
phone_width = 76.4; // [50:1:100]

claw_wall = 3; // [1.5:0.1:6]

// Extra clearance added on top of phone_thickness
claw_clearance = 0.4; // [0:0.1:2]

// Rail bar cross-section (rectangular, so the slider can't spin on it --
// the leadscrew runs alongside, parallel, and only handles the pulling
// force, not anti-rotation)
rail_w = 8; // [5:0.5:14]
rail_h = 6; // [4:0.5:12]
rail_clearance = 0.3; // [0.1:0.05:0.8]

/* [Clamp Screw] */

// Printed thread diameter/pitch -- coarser than standard metric prints far
// more reliably and needs fewer turns to adjust
clamp_screw_dia = 7; // [3:0.5:8]
clamp_screw_pitch = 2; // [1:0.1:3]

// Extra clearance the printed male thread gets cut with, beyond the
// threads.scad library default (0.4) -- a real print came back with the
// screw completely seized in the bearing bosses (couldn't be forced by
// hand), so both this and bearing_clearance below were bumped up well
// past the "looks fine in CAD" nominal fit: FDM holes consistently print
// undersized and shafts/threads oversized relative to the modeled
// dimensions, so a clearance that's mathematically correct in the model
// is routinely too tight in the real part. Re-test with a small printed
// sample (just a short screw stub + one bearing boss) before committing
// to the full multi-hour combined print again.
thread_tolerance = 0.8; // [0.4:0.1:1.5]

// Radial clearance between the screw's plain shaft and the bearing
// bosses' through-bore (center_bearing_and_rail()) -- kept separate from
// rail_clearance below, which is for the sliding rail-channel fit, a
// different kind of joint with different tolerance needs than a free-
// spinning shaft-in-a-hole bearing.
bearing_clearance = 0.6; // [0.3:0.05:1.2]

// Small joints between separately-printed halves (the split pivot
// collar, the rod-to-rail connection) -- NOT the same as clamp_screw_dia,
// which is the big self-centering leadscrew. These just hold two mating
// faces shut.
//
// NO METAL ANYWHERE in this design, by hard requirement -- not even a
// small machine screw. Held instead with a plain friction-fit pin cut
// from a length of the same 1.75mm filament the parts are printed from,
// pushed through a straight round hole in both mating faces and glued.
// (An earlier version of this design used small self-tapping M3 screws
// here -- that's metal hardware and doesn't belong in this design at
// all; a printed helical thread was also tried and rejected as too
// fragile at this small a diameter, and separately produced a large
// ~1580mm^3 bogus overlap in an intersection() check, isolated to the
// ScrewHole() cuts specifically -- the same raw, uncut union() overlapped
// by only ~1mm^3 worth of facets.) Both mating holes are the SAME
// diameter (a plain friction-fit pin doesn't thread into anything, so
// there's no clearance-side/pilot-side distinction the way a screw
// needed). Sized a bit over nominal filament diameter, not under, since
// FDM holes consistently print undersized relative to the modeled
// dimension (the same lesson as thread_tolerance/bearing_clearance
// above) -- re-test with a small printed sample before committing to the
// full print.
filament_pin_dia = 1.75; // [1.5:0.05:3.2]
filament_pin_hole_dia = filament_pin_dia + 0.2;

// Length of each slider block along the rail (thread + rail-channel
// bearing length -- longer resists tilting/binding better)
slider_len = 14; // [8:1:30]

// Knurled turning knob at one end
knob_dia = 14; // [8:0.5:24]
knob_h = 8; // [3:0.5:16]

// Retention flange at the screw's center -- captured between two bearing
// bosses on the rail so the screw can spin freely but can't slide
// axially. A SEPARATE part (see flange_nut() below), threaded onto the
// screw and glued, not molded onto the screw itself -- otherwise it can
// never be inserted (wider than either boss's own bore, no matter which
// end you try).
center_flange_dia = 12; // [8:0.5:20]
center_flange_h = 2; // half-thickness [1:0.2:4]
flange_nut_thickness = 2 * center_flange_h; // fits center_gap with margin

/* [Hidden] */
$fn = 48;

// ---------------------------------------------------------------------
// Connector: rebuilt natively in OpenSCAD from measurements taken off
// connector_only.stl (the real, watertight "slides into the controller"
// piece), rather than imported as an opaque mesh -- so it can be freely
// extended/reinforced without guessing what's safe to touch.
//
// Native frame: X = width (24.8mm), Y = insertion axis (slides toward -Y,
// exposed end at Y=1), Z = plate thickness (tab posts rise toward +Z).
// Tab-clip size/position/profile, the plate footprint, and the USB-C slot
// are measured to match the reference mesh (these mate with real
// hardware); the corner fillets and the small alignment nub are close
// visual approximations, not exact -- they carry no mechanical function.
//
// The tabs are NOT plain posts -- they're snap-fit barbs: a base flush
// with the plate surface (no riser gap), blending immediately into a
// constant-width neck that slides through the controller's narrow lower
// opening, then a head that flares out in the wider pocket beyond.
plate_w = 24.8; plate_l = 27; plate_t = 2.11; plate_corner_r = 2;
tab_y = -10.0; tab_l = 8.0;

// Depth budget measured off the real controller: 8mm total, base to head
// tip, starting flush at the plate surface (Z = plate_top_z) -- confirmed
// by hand-sketch (option D) that the neck must start with zero gap/recess
// below it, not sit atop a tall separate base riser like the first cut did.
plate_top_z = -4.0; plate_bottom_z = -6.11;
tab_z0 = plate_top_z;
// 4mm total depth -- confirmed as the better fit from a printed A/B test
// against the 3.5mm variant (connector_plate_4mm.scad). Neck/head split
// scaled proportionally to match.
tab_base_blend_h = 0.34; // short transition from the wide base footprint to the neck, right at the plate surface
tab_z_neck_top = tab_z0 + 2.63; // neck runs most of the depth budget
tab_z1 = tab_z0 + 4.0; // full measured depth budget, head tip

// Neck inner-gap measured directly off the real controller with calipers
// (14.85mm, facing edges) -- center-to-center = 14.85 + neck_w = 16.65mm.
// base_x (the structural bond to the plate) stays at the reference mesh's
// original position; only neck/head -- the part that actually engages the
// controller -- are repositioned, preserving the previous midpoint.
tab1_base_x = -16.0; tab1_neck_x = -14.375;
tab2_base_x = 2.2; tab2_neck_x = 2.275;
// Each head flares away from the slot (not toward it) to avoid colliding
// with it now that the necks sit closer to center: tab1 keeps its neck's
// RIGHT edge flush and widens left; tab2 keeps its neck's LEFT edge flush
// and widens right.
tab1_head_x = tab1_neck_x - 1.7; // = tab1_neck_x + tab_neck_w - tab_head_w, right-edge flush
tab2_head_x = tab2_neck_x; // left-edge flush

// neck_w capped just under 1.85mm (the real controller's lower-opening
// width, measured) since the neck has to slide through it; head_w capped
// just under 3.6mm (measured max for the wider pocket beyond) -- both
// maximized within those limits for retention strength.
tab_base_w = 3.2; tab_neck_w = 1.8; tab_head_w = 3.5;
slot_x = -11.5; slot_y = -9; slot_w = 12.45; slot_h = 7; slot_corner_r = 1.2;
nub_x = -5.2; nub_y = -15.6; nub_r = 1.3;

module tab_clip(base_x, neck_x, head_x) {
    hull() {
        translate([base_x, tab_y, tab_z0]) cube([tab_base_w, tab_l, 0.02]);
        translate([neck_x, tab_y, tab_z0 + tab_base_blend_h]) cube([tab_neck_w, tab_l, 0.02]);
    }
    translate([neck_x, tab_y, tab_z0 + tab_base_blend_h])
        cube([tab_neck_w, tab_l, tab_z_neck_top - (tab_z0 + tab_base_blend_h)]);
    hull() {
        translate([neck_x, tab_y, tab_z_neck_top]) cube([tab_neck_w, tab_l, 0.02]);
        translate([head_x, tab_y, tab_z1 - 0.02]) cube([tab_head_w, tab_l, 0.02]);
    }
}

module connector_plate_native() {
    difference() {
        union() {
            translate([-17.7, -26, plate_bottom_z])
                linear_extrude(plate_t)
                    hull()
                        for (x = [plate_corner_r, plate_w - plate_corner_r])
                            for (y = [plate_corner_r, plate_l - plate_corner_r])
                                translate([x, y]) circle(r = plate_corner_r);
            tab_clip(tab1_base_x, tab1_neck_x, tab1_head_x);
            tab_clip(tab2_base_x, tab2_neck_x, tab2_head_x);
            translate([nub_x, nub_y, plate_top_z]) sphere(r = nub_r, $fn = 24);
        }
        translate([0, 0, plate_bottom_z - 1])
            linear_extrude(plate_t + 2)
                hull()
                    for (x = [slot_x + slot_corner_r, slot_x + slot_w - slot_corner_r])
                        for (y = [slot_y + slot_corner_r, slot_y + slot_h - slot_corner_r])
                            translate([x, y]) circle(r = slot_corner_r);
    }
}

// Reverted to the original (4-renders-checkpoint) reorientation -- plate's
// outer end sits at the local origin facing +Z, ready for the arm -- PLUS
// exactly one new change on top: 180 degrees around the axis perpendicular
// to the plate, through the nub ("stick a pin into the nub and rotate"),
// an in-plane spin around native Z through the point (nub_x, nub_y) --
// not the origin, so it's built as translate-rotate-translate around that
// point rather than a plain rotate(). Nothing else changed from the
// checkpoint; the back-face flip and its downstream changes (disabling
// connector_bulk(), re-anchoring arm()'s base) are reverted so this one
// change can be evaluated on its own.
module connector() {
    rotate([90, 0, 0])
        translate([5.3, -1, 2.55])
            translate([nub_x, nub_y, 0])
                rotate([0, 0, 180])
                    translate([-nub_x, -nub_y, 0])
                        connector_plate_native();
}

// USB-C passthrough slot in the post-reorientation world frame -- derived
// from the same native slot_x/y/w/h via connector()'s FULL transform chain
// (translate to nub, rotate 180 about Z, translate back, translate
// [5.3,-1,2.55], rotate 90 about X), which composes to:
//   world_x = 2*nub_x - native_x + 5.3
//   world_z = 2*nub_y - native_y - 1
//   world_y = thickness axis, unaffected by the in-plane spin, full
//             through-range as before
// (world_y = thickness axis, unaffected by the in-plane spin, full
// through-range as before). Both native ranges flip order under the
// 2*nub-minus-native mapping, so take min() of the two endpoints.
module usb_slot_clearance() {
    slot_wx0 = min(2 * nub_x - slot_x + 5.3, 2 * nub_x - (slot_x + slot_w) + 5.3);
    slot_wz0 = min(2 * nub_y - slot_y - 1, 2 * nub_y - (slot_y + slot_h) - 1);
    translate([slot_wx0, -3.55, slot_wz0])
        cube([slot_w, 3.55 + bulk_depth + 10, slot_h]);
}

// Reinforcement slab bonded flush to the connector's BACK face -- the side
// opposite the tab posts (world +Y), i.e. straight into the plate's own
// thickness axis, away from the pins that do the actual mating. X/Z extent
// matches the plate's actual world-space footprint (via the same
// 2*nub-minus-native mapping as usb_slot_clearance() above) plus a margin,
// extended by bulk_depth in +Y. Never touches the tab-post side.
module connector_bulk() {
    bulk_wx0 = min(2 * nub_x - (-17.7) + 5.3, 2 * nub_x - (-17.7 + plate_w) + 5.3) - bulk_margin;
    bulk_wx1 = max(2 * nub_x - (-17.7) + 5.3, 2 * nub_x - (-17.7 + plate_w) + 5.3) + bulk_margin;
    bulk_wz0 = min(2 * nub_y - (-26) - 1, 2 * nub_y - (-26 + plate_l) - 1) - bulk_margin;
    bulk_wz1 = max(2 * nub_y - (-26) - 1, 2 * nub_y - (-26 + plate_l) - 1) + bulk_margin;
    difference() {
        translate([bulk_wx0, 3.55, bulk_wz0])
            cube([bulk_wx1 - bulk_wx0, bulk_depth, bulk_wz1 - bulk_wz0]);
        usb_slot_clearance();
        // Corner relief: verified via a full 360-degree rotation sweep of
        // the clamp assembly (checking intersection() volume against
        // base_assembly() at every angle) that the rail grazes exactly
        // this corner -- far Y face meets max Z face -- at the DS/PC
        // target positions (spin=90/270), ~25mm^3 overlap. Not a mid-
        // rotation transient; those are the two positions the mechanism
        // actually has to reach. Sized with margin over the measured
        // overlap (2.7mm x 1.8mm).
        translate([bulk_wx0 - 1, 3.55 + bulk_depth - 4, bulk_wz1 - 3])
            cube([bulk_wx1 - bulk_wx0 + 2, 5, 4]);
    }
}

// Cantilever fixed at the connector, loaded at the pivot end -- so it's
// widest/thickest at the connector (highest bending stress) and gets a
// second, smaller gusset at the pivot end blending into the flange
// diameter (a stress concentration / attachment area, even though it
// carries less bending moment than the base). No abrupt thin-blade-meets-
// boss butt joint at either end.
//
// The base gusset's local anchor (y=0, z=-2) does NOT land at world (Y=0,
// Z=0) once rotate([-arm_angle,0,0]) is applied -- it lands at world Y =
// -2*sin(arm_angle), Z = -2*cos(arm_angle). arm_y0/arm_z0 are the extra
// offsets, applied AFTER the rotate (so they're a pure world-space shift),
// that cancel exactly that and land the anchor flush on the back face
// (world Y = -(plate_bottom_z+2.55), same face connector_bulk() bonds to)
// and centered on the plate's actual world-Z footprint (same 2*nub_y-minus-
// native mapping as connector_bulk()'s bulk_wz0/bulk_wz1) -- so the whole
// arm grows outward from the middle of the back face, instead of leaking
// into the tab/controller-wall zone (the old Y=0 bug) or barely grazing
// one corner of the reinforcement pad (the old Z=0 bug, once the pad's own
// Z-footprint was corrected for the 180 degree spin).
arm_y0 = -(plate_bottom_z + 2.55) + 2 * sin(arm_angle);
arm_z0 = (2 * nub_y - (-26) - 1 + 2 * nub_y - (-26 + plate_l) - 1) / 2 + 2 * cos(arm_angle);

module arm() {
    straight_len = max(0.02, arm_length - 2 * arm_gusset_len + 0.02);
    translate([0, arm_y0, arm_z0])
    rotate([-arm_angle, 0, 0]) {
        hull() {
            translate([-arm_base_width / 2, 0, -2])
                cube([arm_base_width, arm_base_thickness, 0.01]);
            translate([-arm_width / 2, -arm_thickness / 2, arm_gusset_len])
                cube([arm_width, arm_thickness, 0.01]);
        }
        translate([-arm_width / 2, -arm_thickness / 2, arm_gusset_len - 0.01])
            cube([arm_width, arm_thickness, straight_len]);
        hull() {
            translate([-arm_width / 2, -arm_thickness / 2, arm_length - arm_gusset_len])
                cube([arm_width, arm_thickness, 0.01]);
            // A plain cylinder(d=pivot_flange_dia) here would sit in the
            // arm's own (tilted) local XY plane -- NOT the pivot flange's
            // actual plane, since the shaft axis is rotate([-90+pivot_tilt,
            // 0,0]) applied in WORLD space, one level up. Countering with
            // rotate([arm_angle-90+pivot_tilt,0,0]) here (angles about the
            // same X axis just add) makes this cylinder's axis land exactly
            // on the real shaft axis once arm()'s own rotate(-arm_angle) is
            // applied -- so the arm blends flush into the flange face-on
            // instead of meeting it edge-on as a thin, weak sliver. Given
            // real height (not a razor-thin cap) so it's a solid boss, not
            // a membrane. Spans z=-arm_thickness to z=0 (NOT centered) so
            // it sits entirely on the arm's own side of arm_end, flush
            // against the near flange's face -- never crossing z=0 into
            // the shaft, where the rotating collar needs that whole span
            // clear to spin (a centered boss used to sit dead center of
            // the collar's clearance zone and permanently block rotation).
            translate([0, 0, arm_length])
                rotate([arm_angle - 90 + pivot_tilt, 0, 0])
                    translate([0, 0, -arm_thickness])
                        cylinder(d = pivot_flange_dia, h = arm_thickness);
        }
    }
}

// World-space point where the arm ends and the pivot sits -- same
// arm_y0/arm_z0 offsets as arm() itself, so the pivot stays attached to
// the arm's actual tip. (The old formula added a stray bulk_depth term in
// Z that didn't match arm()'s real geometry at all -- a pre-existing bug,
// now replaced by the correct arm_z0-based offset.)
arm_end = [0, arm_y0 + arm_length * sin(arm_angle), arm_z0 + arm_length * cos(arm_angle)];

// Fixed side of the print-in-place pivot: a shaft with a retaining flange
// on each end, rigidly part of the base/arm assembly. Tilted by pivot_tilt
// on top of the base -90 (see the [Pivot] group comment) so the screen
// faces the user and the clamp clears the arm/controller while rotating.
//
// The shaft runs from arm_end (z=0, near flange right there, fused against
// the arm's own boss) OUTWARD to z=pivot_shaft_len (far flange) -- it does
// NOT straddle arm_end symmetrically. A centered shaft used to put the
// collar's entire rotating clearance zone right on top of arm_end, which
// is exactly where the arm's own solid material has to be -- a permanent
// collision, not just an edge case (the arm blocked the clamp at every
// rotation angle). Offsetting the whole shaft to one side keeps the arm's
// bulk and the collar's swept volume on separate turf.
module pivot_pin() {
    translate(arm_end)
        rotate([-90 + pivot_tilt, 0, 0]) {
            cylinder(d = pivot_shaft_dia, h = pivot_shaft_len);
            cylinder(d = pivot_flange_dia, h = pivot_flange_h);
            translate([0, 0, pivot_shaft_len - pivot_flange_h])
                cylinder(d = pivot_flange_dia, h = pivot_flange_h);
        }
}

// Rotating side of the pivot: a collar with clearance around the shaft,
// captured axially between the two flanges. Separate solid from pivot_pin()
// -- not unioned with it -- so the slicer prints both with the clearance
// gap intact and they end up mechanically interlocked, not fused.
//
// Four sections, stacked continuously along the true axis:
//  1. bearing tube -- hollow around the bare shaft, between the two
//     flanges (shortened slightly to make room for the taper below).
//  2. a TAPER, both OD and bore growing smoothly from the bearing tube's
//     own size up to the cap's wider size. Required, not cosmetic: a flat
//     step straight from OD=12/bore=7 to OD=21/bore=15 leaves the two
//     tube walls as non-overlapping annuli -- literally a ring-shaped gap
//     with no material connecting them at all. Caught this via an actual
//     connected-components check on the exported mesh (clamp_center came
//     back as 2 disconnected pieces split exactly at this seam), not by
//     assuming a flat join would work.
//  3. a short hollow CAP clearing the far flange -- the flange (14mm dia)
//     is bigger than the bearing tube's own OD (12mm), so simply
//     extending the skinny tube through it is geometrically impossible
//     (verified earlier: an intersection() check caught a real 384mm^3
//     overlap trying exactly that). The cap's bore has to clear the whole
//     flange, not just the bare shaft, so it's wider than the tube --
//     already full-width by the time it reaches the flange, since the
//     taper above completes before this section starts.
//  4. a SOLID standoff rod, past the flange where nothing is left to
//     clear -- reaches all the way to the true axis line (X=0,Y=0) at
//     this depth, which is what lets the claws attach there and grip the
//     phone centered on both axes instead of only alongside the collar.
collar_taper_len = 3;
collar_between_len = pivot_shaft_len - 2 * pivot_flange_h - 2 * pivot_clearance - collar_taper_len;
collar_cap_bore_dia = pivot_flange_dia + 2 * pivot_clearance;
// Wall padding wide enough that the rod (same diameter as the cap) has
// real margin against the flange-relief notch below -- the notch
// (radius center_flange_dia/2+bearing_clearance=6.6mm) is offset only
// screw_y=4mm from the rod's own center, so 6.6+4=10.6mm already
// EXCEEDS the old wall's rod radius (10.5mm) by a hair. That's not a
// clearance problem, it's the notch actually bisecting the rod's
// circular cross-section into two disconnected crescents near the
// notch's own center -- confirmed by isolating the exact Z-range via a
// connected-components check (2 separate pieces, matching a rendered
// cross-section that visibly showed a large crescent and a small,
// disconnected sliver crescent). A thin numerical fragility fix (extra
// overlap margins, a reinforcement spine) couldn't help because the
// separation is a real, large-scale geometric fact, not a sliver
// artifact. 13mm of wall gives the rod (radius 14mm here) a real ~3.4mm
// margin over the notch's 10.6mm reach.
collar_cap_outer_dia = collar_cap_bore_dia + 13;
collar_cap_len = pivot_flange_h + 2 * pivot_clearance;

module pivot_collar_solid() {
    taper_len = collar_taper_len;
    between_len = collar_between_len;
    cap_bore_dia = collar_cap_bore_dia;
    cap_outer_dia = collar_cap_outer_dia;
    cap_len = collar_cap_len;
    translate(arm_end)
        rotate([-90 + pivot_tilt, 0, 0]) {
            translate([0, 0, pivot_flange_h + pivot_clearance])
                difference() {
                    cylinder(d = pivot_collar_dia, h = between_len);
                    translate([0, 0, -1])
                        cylinder(d = pivot_shaft_dia + 2 * pivot_clearance, h = between_len + 2);
                }
            translate([0, 0, pivot_flange_h + pivot_clearance + between_len])
                difference() {
                    hull() {
                        cylinder(d = pivot_collar_dia, h = 0.01);
                        translate([0, 0, taper_len])
                            cylinder(d = cap_outer_dia, h = 0.01);
                    }
                    translate([0, 0, -1])
                        hull() {
                            cylinder(d = pivot_shaft_dia + 2 * pivot_clearance, h = 0.01);
                            translate([0, 0, taper_len + 1])
                                cylinder(d = cap_bore_dia, h = 0.01);
                        }
                }
            translate([0, 0, pivot_flange_h + pivot_clearance + between_len + taper_len])
                difference() {
                    cylinder(d = cap_outer_dia, h = cap_len);
                    translate([0, 0, -1])
                        cylinder(d = cap_bore_dia, h = cap_len + 2);
                }
            // Rod reaches toward the rail, at the TRUE pivot axis (X=0,
            // Y=0 in in_pivot_frame() terms) -- NOT all the way to
            // in_pivot_frame()'s own origin itself, which is the phone's
            // Z-center (claw_gap wide, symmetric): a rod reaching all the
            // way there would dip into the phone's clearance zone no
            // matter how long pivot_standoff is (tried that first --
            // moving the rod's end and the origin together never closes
            // a gap between them, confirmed via an intersection() check).
            //
            // But the pivot axis (X=0,Y=0) is NOT the same point as the
            // rail's own centerline (screw_y, roughly -4) -- the rod, at
            // its full cap_outer_dia (21mm, sized to clear the shaft's
            // far flange, not sized for this reach), is wide enough that
            // its own axis line passes within the screw's retention
            // flange's radius (center_flange_dia/2=6mm) regardless of
            // how thin the rod is made, at the Z depth where they'd
            // coexist -- a real, unavoidable-by-thinning collision
            // between the rod (part of the ROTATING collar+rail+boss
            // unit) and the flange (part of the SEPARATE screw, which
            // must spin freely relative to that unit). Confirmed via an
            // actual intersection() check (5076 facets of real overlap),
            // not assumed from the rail-notch fix alone -- a real print
            // came back completely fused at the screw's center with only
            // that first notch applied. Fixed the same way: a relief cut
            // through the rod, matching the same flange-clearance
            // cylinder subtracted from the rail in
            // center_bearing_and_rail() above, re-expressed in this
            // module's own local frame (collar-local Z = in_pivot_frame
            // Z + pivot_shaft_len+pivot_clearance+pivot_standoff, X/Y
            // otherwise share the same axes).
            // The relief cut has to span the rod's FULL diameter in X, not
            // just the flange's own narrow thickness: the rod (radius
            // cap_outer_dia/2=10.5) is a disk in the X-Y plane at every Z
            // it occupies, so it reaches out to the screw's centerline
            // (offset only screw_y=-4 away, well inside a 10.5mm radius)
            // across the WHOLE X range where |X| < ~9.7 -- not just where
            // the flange itself sits (+-2mm). A notch scoped to only the
            // flange's own width left the rod still solid across most of
            // that reach, still colliding with the plain threaded shaft
            // there (confirmed via an intersection() check: 4374 facets
            // of real overlap remained after the first, too-narrow cut).
            difference() {
                translate([0, 0, pivot_shaft_len + pivot_clearance])
                    cylinder(d = cap_outer_dia, h = pivot_standoff - claw_gap / 2);
                translate([0, screw_y, screw_z + pivot_shaft_len + pivot_clearance + pivot_standoff])
                    rotate([0, 90, 0])
                        cylinder(d = center_flange_dia + 2 * bearing_clearance, h = cap_outer_dia + 2, center = true, $fn = 48);
                // Holes for the two filament pins joining the rod's tip
                // down into center_bearing_and_rail()'s rod_connect_shelf()
                // (see there) -- X/Y match rod_mount_screw1_x/2_x and
                // mount_screw_y exactly, since collar-local X/Y are the
                // same axes as in_pivot_frame's (only Z differs, by the
                // pivot_shaft_len+pivot_clearance+pivot_standoff offset),
                // so no conversion is needed. Open at the rod's own tip
                // face, so a pin can be pre-inserted here (before the rod
                // is brought down onto the shelf) like a standard dowel
                // joint -- see rod_connect_shelf()'s matching hole below.
                rod_tip_z = pivot_shaft_len + pivot_clearance + pivot_standoff - claw_gap / 2;
                translate([rod_mount_screw1_x, mount_screw_y, rod_tip_z - 9])
                    cylinder(d = filament_pin_hole_dia, h = 10);
                translate([rod_mount_screw2_x, mount_screw_y, rod_tip_z - 9])
                    cylinder(d = filament_pin_hole_dia, h = 10);
                // Clearance for the plain rail bar itself, not just the
                // boss -- the rod's widened radius (needed for real
                // margin against the flange notch, see above) is now wide
                // enough to also reach the rail bar at its own center
                // (X=0), a plain touch with no fastener there at all
                // (unlike the boss, which gets the two rod_mount_screw
                // connections above). Cut clear of it and rely only on
                // those two screws for the actual rigid link -- confirmed
                // via an actual intersection() check (64 facets of real
                // overlap) before this fix.
                translate([-16, rail_y0 - 2, rail_z0 - 2 + pivot_shaft_len + pivot_clearance + pivot_standoff])
                    cube([32, rail_w + 4, rail_h + 4]);
                // Same problem, same fix, for the fixed boss (boss1)
                // itself -- the widened rod also swallows most of ITS
                // footprint (boss1's own Y reach is only ~9.5mm, well
                // inside the rod's new 14mm radius), not just its narrow
                // rail-channel notch. Cut clear of boss1's own cube too;
                // the two rod_mount_screw connections (at mount_screw_y=6,
                // well outside boss1's own Y<=1.5 reach, on the separate
                // rod_connect_shelf() the fixed piece grows for exactly
                // this purpose) are unaffected by this cut.
                //
                // Margin widened from -2/+4 to -3/+6 (both here and on
                // boss2 below) after raising clamp_screw_dia from 5 to
                // 7: the boss cube's own cross-section grows with
                // clamp_screw_dia, so the old margin -- comfortable at
                // 5mm -- became too tight at 7mm and left a tiny
                // disconnected sliver in collar_bottom (confirmed via a
                // connected-components check: 2 pieces instead of 1,
                // isolated to this specific cut via a bounding-box render,
                // not the rod_connect_shelf lip below, which was tried
                // first and ruled out).
                translate([-center_gap / 2 - bearing_len - 3, screw_y - clamp_screw_dia / 2 - claw_wall - 3, boss_bottom - 3 + pivot_shaft_len + pivot_clearance + pivot_standoff])
                    cube([bearing_len + 6, clamp_screw_dia + 2 * claw_wall + 6, (boss_top - boss_bottom) + 6]);
                // Same problem, same fix, for boss2 (+X side, restored as
                // fixed once the flange became a separate glued-on part --
                // see flange_nut() -- rather than a removable boss_cap).
                // ~1700mm^3 of real overlap (confirmed via an
                // intersection() check on the raw, uncut shapes -- not a
                // sliver, and not a thread-cutting artifact either,
                // despite first looking like one) between the rod's full
                // width and this boss's own footprint, mirroring boss1.
                translate([center_gap / 2 - 3, screw_y - clamp_screw_dia / 2 - claw_wall - 3, boss_bottom - 3 + pivot_shaft_len + pivot_clearance + pivot_standoff])
                    cube([bearing_len + 6, clamp_screw_dia + 2 * claw_wall + 6, (boss_top - boss_bottom) + 6]);
                // rod_connect_shelf()'s clearance is the same idea, EXCEPT
                // it stops 1.5mm short of the rod's own natural tip
                // (Z=boss_top), leaving a thin, full-width lip there --
                // the rod's own ordinary, unmodified tip surface (present
                // everywhere it isn't deliberately cut away) is already
                // plenty of bearing area for a small screw head, no
                // separate "boss" needed. A first attempt tried
                // preserving two small round islands reaching further
                // down instead, which still collided with the shelf's
                // own bulk there (505mm^3 of real overlap, confirmed via
                // an intersection() check) -- solid material that deep
                // was never actually needed, just a flat surface right at
                // the tip.
                translate([-center_gap / 2 - bearing_len - 2, screw_y + clamp_screw_dia / 2 + claw_wall - 1 - 3, boss_bottom - 2 + pivot_shaft_len + pivot_clearance + pivot_standoff])
                    cube([bearing_len + 4, (mount_screw_y + 4 - (screw_y + clamp_screw_dia / 2 + claw_wall) + 1) + 5, (boss_top - boss_bottom) + 0.5]);
            }
        }
}

// Split clamshell collar: pivot_collar_solid() cut in half along the
// Y=0 plane (which contains the pivot's own axis) -- but ONLY through
// the bearing tube/taper/cap section, not the solid rod past it. The rod
// has no bore to open up (nothing wraps around it -- it's solid,
// structural material reaching to the rail, not part of the pin/collar
// bearing fit at all), and its own flange-relief notch is asymmetric
// (centered at screw_y=-4, so almost entirely on the -Y side) -- a plain
// Y=0 split there doesn't leave two clean halves, it fragments the
// bottom half into 3 disconnected pieces (confirmed via a connected-
// components check, both with and without the tabs present, isolating
// the split itself -- not the tabs or screw holes -- as the cause). So
// the rod stays whole and goes entirely with the bottom half; only the
// tube/cap get a clamshell split, with two tab pairs (not three).
collar_tab_span = 7; // each tab reaches this far past Y=0 on either side
collar_tab_out = 6; // how far a tab extends beyond the collar's own outer surface
collar_tab_thick = 8; // tab extent along the collar's own Z axis
collar_tab1_z = pivot_flange_h + pivot_clearance + collar_between_len / 2; // mid bearing tube
collar_tab1_r = pivot_collar_dia / 2;
collar_tab2_z = pivot_flange_h + pivot_clearance + collar_between_len + collar_taper_len + collar_cap_len / 2; // mid cap
collar_tab2_r = collar_cap_outer_dia / 2;
collar_rod_start = pivot_flange_h + pivot_clearance + collar_between_len + collar_taper_len + collar_cap_len;

module collar_tab(z_center, outer_r) {
    translate(arm_end)
        rotate([-90 + pivot_tilt, 0, 0])
            translate([outer_r - 2, -collar_tab_span, z_center - collar_tab_thick / 2])
                cube([collar_tab_out + 2, 2 * collar_tab_span, collar_tab_thick]);
}

module collar_tabs() {
    collar_tab(collar_tab1_z, collar_tab1_r);
    collar_tab(collar_tab2_z, collar_tab2_r);
}

module collar_half_space(positive) {
    // The cap's own bore cut (see pivot_collar_solid() above) is 2mm
    // taller than the cap itself and centered on it, so it overshoots
    // 1mm PAST collar_rod_start into the rod's own territory -- meaning
    // the first ~1mm of the "solid" rod is actually still hollow. Cutting
    // the unsplit-rod region right at collar_rod_start-1 (inside that
    // hollow overshoot) produced a small disconnected sliver there
    // (confirmed via a connected-components check isolating this Z-cut
    // alone, with no Y-split involved at all). Pushed 3mm further in --
    // safely past the bore overshoot, and still safely before the
    // flange-relief notch's own start (~6.7mm further still) -- so the
    // first few mm past the cap stay Y-split (fine, no notch there yet)
    // and only genuinely, unambiguously solid rod is left unsplit.
    rod_unsplit_start = collar_rod_start + 3;
    translate(arm_end)
        rotate([-90 + pivot_tilt, 0, 0]) {
            translate([-50, positive ? 0 : -300, -50])
                cube([100, 300, rod_unsplit_start + 50]);
            if (!positive)
                translate([-50, -300, rod_unsplit_start - 1])
                    cube([100, 600, 300]);
        }
}

// Cuts the tab pin hole using pivot_collar's OWN self-transforming
// pattern (translate(arm_end) rotate([-90+pivot_tilt,0,0]) applied
// directly around a LOCAL-frame cut), matching collar_tab() exactly --
// NOT ScrewHole()'s usual position/rotation convenience wrapper (not
// that a filament pin needs ScrewHole() at all, but the same transform
// pitfall applies to any cutter nested under an outer translate/rotate):
// pivot_collar_solid()/collar_tabs() already self-transform internally,
// so nesting a cutter under a second outer translate/rotate
// double-applies that transform (confirmed via a connected-components
// check: pivot_collar_bottom() split into 3 disconnected pieces, back
// when this was tried with ScrewHole()). A hand-computed single combined
// world-space rotation for the cutter was tried next and also came out
// misaligned -- confirmed by rendering the actual cutter shape next to
// collar_tab(), not just a position marker. This version reuses the
// exact transform collar_tab() itself uses, so cutter and tab are
// guaranteed to agree. Used identically by both halves -- a plain
// friction-fit pin doesn't thread into anything, so unlike the old
// self-tapping screw there's no clearance-side/pilot-side distinction.
module collar_tab_pin_hole(z_center, outer_r) {
    translate(arm_end)
        rotate([-90 + pivot_tilt, 0, 0])
            translate([outer_r + collar_tab_out / 2, -collar_tab_span - 1, z_center])
                rotate([-90, 0, 0])
                    cylinder(d = filament_pin_hole_dia, h = 2 * collar_tab_span + 2);
}

module pivot_collar_top() {
    difference() {
        intersection() {
            union() {
                pivot_collar_solid();
                collar_tabs();
            }
            collar_half_space(true);
        }
        collar_tab_pin_hole(collar_tab1_z, collar_tab1_r);
        collar_tab_pin_hole(collar_tab2_z, collar_tab2_r);
    }
}

module pivot_collar_bottom() {
    difference() {
        intersection() {
            union() {
                pivot_collar_solid();
                collar_tabs();
            }
            collar_half_space(false);
        }
        collar_tab_pin_hole(collar_tab1_z, collar_tab1_r);
        collar_tab_pin_hole(collar_tab2_z, collar_tab2_r);
    }
}

// Screw-adjustable clamp, car/bike-mount claw style: a rail runs along the
// phone's LONG axis with a small hook claw at each end -- NOT a sandwich
// plate, so the screen and back stay fully exposed between the two claws.
// One claw is fixed to the rail (and to the pivot collar); the other rides
// a printed leadscrew that runs alongside the rail and threads it inward
// to squeeze the phone's short edges, or back out to release/resize.
//
// Local frame (inside in_pivot_frame()): X = along the rail (phone's long
// axis), Z = gap axis (= pivot axis = phone face normal, so rotating the
// pivot keeps the phone flat-facing the same way while swapping which
// edge-pair the claws grip between DS/portrait and PC/landscape), Y = how
// far each claw's lip reaches over the phone's face near the edge.
module in_pivot_frame() {
    translate(arm_end)
        rotate([-90 + pivot_tilt, 0, 0])
            translate([0, 0, pivot_shaft_len + pivot_clearance + pivot_standoff])
                children();
}

claw_gap = phone_thickness + claw_clearance;

// The pivot sits at the rail's CENTER (X=0), not at one end -- so the
// phone is balanced on the rotation axis instead of hanging mostly to one
// side when it swings between portrait and landscape. The fixed claw (and
// the leadscrew's knob) sit at the near end, X = rail_x0.
rail_x0 = -rail_length / 2;

// Rail + leadscrew sit behind the claws (-Y, away from the phone), stacked
// in Z so neither intrudes on the gap where the phone's edge sits.
//
// rail_z0 is pushed fully behind the phone's Z-clearance zone (Z=-claw_gap
// /2 to +claw_gap/2), not centered on Z=0 like it used to be. That old
// centering was fine when the phone was Y-offset (old design: phone and
// rail never shared the same Y range, so a Z overlap between them didn't
// matter). Now the phone is Y-CENTERED and spans the same Y range the
// rail sits in, so any Z overlap between them is a real collision --
// confirmed via an actual intersection() check (7950mm^3 of real overlap
// with the old centered rail_z0). Pushing the rail entirely into -Z
// behind the phone's zone, and having the collar's standoff rod reach
// only as far as the rail's own far edge (not into the phone's zone),
// resolves it.
//
// The bound has to account for the BEARING BOSS too, not just the rail
// bar -- the boss sits screw_gap_to_rail + clamp_screw_dia/2 + claw_wall
// further forward than the rail's own edge, and a first pass that only
// pushed the rail back still left the boss reaching into the phone's zone
// (another real overlap caught the same way, not assumed away).
screw_gap_to_rail = 1.5;
rail_y0 = -rail_w;
rail_z0 = -(claw_gap / 2 + rail_h + screw_gap_to_rail + clamp_screw_dia + claw_wall);
screw_y = rail_y0 + rail_w / 2;
screw_z = rail_z0 + rail_h + screw_gap_to_rail + clamp_screw_dia / 2;

// L-bracket grip, not a sandwich: only the BOTTOM lip (Z=-claw_gap/2, the
// phone's back-facing side) exists -- the TOP lip is gone entirely, so
// nothing caps the phone's front face. The phone's short edge sets down
// onto the bottom lip from the open +Z side.
//
// The other leg of the L is a wall along the RAIL axis (X), not the reach
// axis (Y) -- positioned at each claw's OUTWARD tip (away from the rail's
// center/the other claw), spanning the full Y reach. This is the actual
// backstop: as the screw draws the two claws together, the phone's short
// edge presses against this wall, which is what transmits the grip force
// -- not a sandwich-lip squeeze at all.
//
// "Outward" flips with which claw this is: for the right claw (mirrored
// = false), x0 is the positive/near-center end and x0+claw_width is the
// far/outward end; for the left claw (mirrored = true) it's the other
// way around (x0 itself, the most-negative end, is outward).
//
// The wall's span along X starts 1mm inside the slider boss's own
// footprint (wall_span = claw_width - slider_len + 1), not right at the
// claw's outward edge alone -- a wall confined to only the claw's own
// overhang past the boss doesn't share any X range with the boss at all
// (claw_width=18 vs slider_len=14, a 4mm gap with zero real overlap), so
// nothing would bridge the bottom lip (Z=[-8.2,-5.2]) up to the boss's Z
// range (~[1.5,12.5]) -- confirmed by an actual connected-components
// check catching that exact split before this 1mm overlap was added.
module claw(x0, mirrored) {
    half_reach = claw_reach / 2;
    wall_span = claw_width - slider_len + 1;
    wall_x = mirrored ? x0 : x0 + claw_width - wall_span;
    translate([x0, -half_reach, -claw_gap / 2 - claw_wall])
        cube([claw_width, claw_reach, claw_wall]);
    translate([wall_x, -half_reach, -claw_gap / 2 - claw_wall])
        cube([wall_span, claw_reach, claw_gap + 2 * claw_wall]);
}

module rail() {
    translate([rail_x0, rail_y0, rail_z0])
        cube([rail_length, rail_w, rail_h]);
}

// Self-centering: the screw has RIGHT-handed thread from center to +X and
// LEFT-handed thread (mirrored -- see dual_thread_screw() below) from
// center to -X. Turning it one way draws BOTH claws inward equally, the
// other way pushes both out equally -- the midpoint between them never
// moves off X=0, so the phone stays centered on the pivot at any grip
// width, not just one setting. This is what a real self-centering vise
// does with opposed threads on one rod.

// Gap between the two center bearing bosses that the screw's retention
// flange sits in -- wider than the flange so it can spin freely, narrow
// enough that the flange (not the thread) is what the bosses thrust
// against, so the rod can't walk sideways under load.
center_gap = 2 * center_flange_h + 2 * rail_clearance;

// Both bearing bosses are fixed, straddling center_gap -- back to the
// very first version of this design, before a removable boss_cap()
// existed at all. That removable boss existed only to solve getting the
// screw's flange into the gap; with the flange now a SEPARATE part
// (flange_nut() above) threaded on and glued AFTER the bare, flangeless
// screw is already sitting in place, neither boss ever needs to pass
// anything wider than the plain shaft, so both can just be fixed.
// Length of each plain (unthreaded) bearing boss the screw spins in.
bearing_len = 12;
boss_top = screw_z + clamp_screw_dia / 2 + claw_wall;
boss_bottom = screw_z - clamp_screw_dia / 2 - claw_wall;
// Y offset used for the rod-to-rail connection shelf below -- >5.5mm
// from screw_y so it clears the main bore's own radius with margin (see
// rod_connect_shelf()).
mount_screw_y = 6;

// Splitting the collar into two halves (see pivot_collar_top()/
// pivot_collar_bottom() below) means the rod -- which used to fuse
// directly into this same printed piece, the ONLY thing that actually
// held the rotating collar and the rail together as one rigid unit --
// no longer touches anything here at all once collar_bottom is a
// separate print. Without an explicit fastener there, the rail/claws
// wouldn't actually rotate with the collar; they'd just be a loose,
// unattached part sitting nearby. Two more assembly screws, same style
// as the boss_cap ones above, join the rod's tip (in
// pivot_collar_bottom(), see its own clearance holes) down into a shelf
// grown out of the fixed boss here.
rod_mount_screw1_x = -center_gap / 2 - bearing_len * 0.25;
rod_mount_screw2_x = -center_gap / 2 - bearing_len * 0.75;

module rod_connect_shelf(x0) {
    translate([x0, screw_y + clamp_screw_dia / 2 + claw_wall - 1, boss_top - 12])
        cube([bearing_len, mount_screw_y + 4 - (screw_y + clamp_screw_dia / 2 + claw_wall) + 1, 12]);
}

// Both bearing bosses (X<0 and X>0) plus the rail spanning its full
// length, all one fixed piece. Both claws are separate sliding parts.
module center_bearing_and_rail() {
    difference() {
        union() {
            rail();
            translate([-center_gap / 2 - bearing_len, screw_y - clamp_screw_dia / 2 - claw_wall, screw_z - clamp_screw_dia / 2 - claw_wall])
                cube([bearing_len, clamp_screw_dia + 2 * claw_wall, clamp_screw_dia + 2 * claw_wall]);
            translate([center_gap / 2, screw_y - clamp_screw_dia / 2 - claw_wall, screw_z - clamp_screw_dia / 2 - claw_wall])
                cube([bearing_len, clamp_screw_dia + 2 * claw_wall, clamp_screw_dia + 2 * claw_wall]);
            rod_connect_shelf(-center_gap / 2 - bearing_len);
        }
        // Holes for the two rod-to-rail filament pins -- open at the
        // shelf's own top face, so a pin pre-inserted into the rod's
        // matching hole (see pivot_collar_solid() above) seats into these
        // as the rod is brought down onto the shelf, like a standard
        // dowel joint. Same diameter as the rod's own holes (see
        // filament_pin_hole_dia above): a plain friction-fit pin doesn't
        // thread into anything, so there's no separate pilot size needed.
        //
        // Depth (boss_top-10, h=13) is deeper than the naive "match the
        // rod's own 9mm reach" guess (boss_top-8, h=9) would suggest --
        // the old self-tapping-screw version tolerated that shallower cut
        // because its clearance-hole/pilot-hole diameters differed enough
        // to absorb the slop, but the new equal-diameter friction-fit pin
        // holes don't have that slack. Confirmed via an intersection()
        // check between the assembled rod+shelf and a probe cylinder
        // spanning the full intended pin channel: the shallower cut left
        // a small (~2.4mm^3) real blockage right at the shelf's own end
        // of the channel, only found by bisecting the probe to isolate
        // which half the blockage fell in (not from re-deriving the
        // rod/shelf frame math by hand, which gave a wrong answer for the
        // scale of the error). h=13 stays 2mm clear of the shelf's own
        // bottom face (rod_connect_shelf() is 12mm tall) and gives a
        // verified-empty channel, not just a razor-thin numerical zero.
        translate([rod_mount_screw1_x, mount_screw_y, boss_top - 10])
            cylinder(d = filament_pin_hole_dia, h = 13);
        translate([rod_mount_screw2_x, mount_screw_y, boss_top - 10])
            cylinder(d = filament_pin_hole_dia, h = 13);
        // Bore runs the full length through both bosses AND the gap
        // between them (where flange_nut() threads on after assembly).
        translate([-center_gap / 2 - bearing_len - 1, screw_y, screw_z])
            rotate([0, 90, 0])
                cylinder(d = clamp_screw_dia + 2 * bearing_clearance, h = center_gap + 2 * bearing_len + 2);
        // Relief notch for the retention flange, directly under its swept
        // path in the rail -- the flange (center_flange_dia=12, radius 6)
        // is wider than the plain shaft and needs 6mm of clearance from
        // screw_z down to the rail's own top surface, but only had 4mm
        // (screw_gap_to_rail + clamp_screw_dia/2) -- a real ~2mm physical
        // overlap, not just tight clearance: confirmed via an actual
        // intersection() check between center_bearing_and_rail() and
        // dual_thread_screw() (a real ~32mm^3 overlap, not a knife-edge
        // touch), matching a real print where the flange came out fused
        // solid to the rail instead of spinning. Cut only within the
        // flange's own X span (center_gap, the gap next to the fixed
        // boss) so the rail stays solid and connected to the boss
        // everywhere else.
        translate([0, screw_y, screw_z])
            rotate([0, 90, 0])
                cylinder(d = center_flange_dia + 2 * bearing_clearance, h = center_gap + 2, center = true, $fn = 48);
        // Pivot-shaft clearance: in_pivot_frame() centers this whole
        // assembly directly over the pivot axis (local X=0, Y=0), so the
        // rail's own cross-section crosses right where the shaft has to
        // pass. Without this cut the rail prints solid through the shaft's
        // location -- the same effect as if the collar's own bore were
        // plugged, just from a different part. Sized to match the
        // collar's bore (pivot_shaft_dia + clearance) and long enough to
        // clear the whole shaft span regardless of pivot_tilt/arm_angle.
        translate([0, 0, -pivot_shaft_len / 2 - 1])
            cylinder(d = pivot_shaft_dia + 2 * pivot_clearance, h = pivot_shaft_len + 2);
    }
}


// One claw riding the rail, threaded onto whichever half of the screw is
// under it -- `mirrored` picks the matching (opposite-handed) cutter, via
// ScrewHoleMirrored() below. ScrewHole()/ScrewHoleMirrored() only
// transform the CUTTER via position/rotation -- children stay exactly
// where placed, so the solid is built directly in real (world)
// coordinates, not in some local frame that then gets moved.
//
// claw(x0) and the slider's solid blocks are unioned FIRST, then the
// thread and rail-channel are cut ONCE through the combined result --
// NOT the other way around (thread-cut-then-union-with-claw), which looks
// equivalent but isn't: verified via an actual connected-components check
// on the exported mesh that the thread-then-union order left 12-14 small
// fragments where the claw's flat lip faces happened to graze the thread
// cutter's curved boundary near-tangentially (classic CGAL boolean
// fragility on near-coincident surfaces). Doing one cut through one
// already-unioned solid never creates that seam in the first place.
module slider_body_solid(x0) {
    translate([x0, rail_y0, rail_z0]) cube([slider_len, rail_w, rail_h]);
    translate([x0, screw_y - clamp_screw_dia / 2 - claw_wall, screw_z - clamp_screw_dia / 2 - claw_wall])
        cube([slider_len, clamp_screw_dia + 2 * claw_wall, clamp_screw_dia + 2 * claw_wall]);
}

module claw_and_slider_solid(x0, mirrored) {
    claw(x0, mirrored);
    slider_body_solid(x0);
}

module slider_claw(x0, mirrored) {
    difference() {
        if (mirrored)
            ScrewHoleMirrored(clamp_screw_dia, slider_len + 1, position = [x0 - 0.5, screw_y, screw_z], rotation = [0, 90, 0], pitch = clamp_screw_pitch, tooth_angle = 30, tolerance = thread_tolerance) claw_and_slider_solid(x0, mirrored);
        else
            ScrewHole(clamp_screw_dia, slider_len + 1, position = [x0 - 0.5, screw_y, screw_z], rotation = [0, 90, 0], pitch = clamp_screw_pitch, tooth_angle = 30, tolerance = thread_tolerance) claw_and_slider_solid(x0, mirrored);
        translate([x0 - 1, rail_y0 - rail_clearance, rail_z0 - rail_clearance])
            cube([slider_len + 2, rail_w + 2 * rail_clearance, rail_h + 2 * rail_clearance]);
    }
}

// Same as ScrewHole() (see lib/threads.scad) but cuts the mirror-image
// (opposite handed) thread -- mirroring across a plane that CONTAINS the
// thread's own axis inverts a helix's handedness (a basic chirality fact:
// mirror reflections always flip chirality); mirroring END-TO-END (across
// a plane PERPENDICULAR to the axis) would NOT -- it'd just relocate the
// same right-handed thread, which is the mistake to avoid here.
module ScrewHoleMirrored(outer_diam, height, position = [0, 0, 0], rotation = [0, 0, 0], pitch = 0, tooth_angle = 30, tolerance = 0.4) {
    extra_height = 0.001 * height;
    difference() {
        children();
        translate(position)
            rotate(rotation)
            translate([0, 0, -extra_height / 2])
            mirror([1, 0, 0])
            ScrewThread(1.01 * outer_diam + 1.25 * tolerance, height + extra_height, pitch, tooth_angle, tolerance);
    }
}

// The screw itself: right-handed from center to +half_len, left-handed
// (mirrored) from center to -half_len, plus the center retention flange.
half_len = rail_length / 2 - 2;

// Anti-rotation peg for the knob, at the +X tip -- NOT a knurled knob
// fused directly onto the screw. The right claw threads onto this same
// +X section by rotating on from the open tip, moving inward toward the
// (already-captured) center flange; a knob fused right at that tip would
// permanently block it (verified: the right claw's thread bore is wider
// than the shaft but narrower than knob_dia, so it can never pass a
// fused knob, and the flange end is already blocked by the bearing
// bosses -- there'd be no way to get the claw onto the screw at all).
// The knob prints as its own separate part (see knob() below) and is
// glued onto this peg AFTER both claws are threaded on. Square, not
// round, so the glued joint actually transmits turning torque instead
// of relying on glue shear alone. Sized to fit within the thread's own
// ~5mm envelope (peg diagonal 5.66mm > 5mm crest -- close enough that
// the small corner overhang is cosmetic, not a real discontinuity;
// confirmed connected via the same connected-components check used
// throughout this project) so there's no unsupported step at the seam.
peg_size = 4;
peg_len = 4;
// 2mm margin past half_len before the peg starts, purely for print
// tolerance -- the slider's own max travel (x0 = half_len - slider_len,
// keeping its full thread engagement inside [0, half_len]) already lands
// exactly at half_len with zero overlap against a peg placed right at
// half_len (confirmed via an intersection() check against claw() at that
// worst-case position, including the claw's wall -- the screw sits at
// screw_z, offset behind the claw's own Z-center, which is what keeps
// the wall clear even at max extension), but zero clearance in the
// ideal model is too tight to trust against real print tolerance.
peg_z0 = half_len + 2;

// No integral center flange -- see flange_nut() below for why. The
// right- and left-hand threads simply meet at X=0.
module dual_thread_screw() {
    translate([0, screw_y, screw_z])
        rotate([0, 90, 0]) {
            ScrewThread(clamp_screw_dia, half_len, pitch = clamp_screw_pitch, tooth_angle = 30);
            mirror([1, 0, 0])
                translate([0, 0, -half_len])
                    ScrewThread(clamp_screw_dia, half_len, pitch = clamp_screw_pitch, tooth_angle = 30);
            // Plain stub bridging the thread's end to the peg -- without
            // it the peg is a floating, disconnected fragment (the 2mm
            // clearance margin above is empty space, not material).
            translate([0, 0, half_len])
                cylinder(d = clamp_screw_dia, h = peg_z0 - half_len);
            translate([-peg_size / 2, -peg_size / 2, peg_z0])
                cube([peg_size, peg_size, peg_len]);
        }
}

// The screw's retention flange, separate and threaded on AFTER the bare
// screw is already in place, then glued -- not molded onto the screw.
// A flange wide enough to be captured between two bosses (12mm) can
// never fit through EITHER boss's own ~6mm bore, so a screw with an
// integral flange can only ever be inserted from whichever end doesn't
// have a boss yet -- which was the whole reason for making one boss a
// separate, removable boss_cap() part in the first design pass. The
// user pointed out a simpler fix: keep BOTH bosses fixed (like the very
// first version of this design, before boss_cap existed at all), make
// the screw a plain flangeless shaft (slides freely through either
// fixed bore, nothing to catch on), and screw this nut onto the screw's
// own thread from inside the gap between the bosses -- accessible
// precisely because there's no boss material AT the gap -- once the
// screw's center is already sitting there. Threads onto the RIGHT-hand
// half only (not straddling X=0, where the handedness would have to
// flip inside a single nut, which is not physically buildable) and gets
// glued in place afterward so it can't work itself loose.
module flange_nut() {
    ScrewHole(clamp_screw_dia, flange_nut_thickness + 1, position = [0, 0, -0.5], rotation = [0, 0, 0], pitch = clamp_screw_pitch, tooth_angle = 30)
        cylinder(d = center_flange_dia, h = flange_nut_thickness, $fn = 48);
}

// flange_nut(), assembled onto the screw and centered in the gap between
// the two bosses -- factored out into its own module (rather than
// inlined at each call site) specifically so callers that only `use`
// this file, without also `include`-ing it, still get the correct
// screw_y/screw_z/flange_nut_thickness values: a module's own body
// resolves free variables in the scope where the MODULE is defined
// (here), not the caller's scope, so this works correctly even from a
// `use`-only caller where those variable names are otherwise undef.
// Writing `translate([0,screw_y,screw_z]) ... flange_nut()` directly in
// a `use`-only caller silently resolves screw_y/screw_z to undef (~0),
// placing the nut at the local origin instead of on the screw -- exactly
// the bug that produced a floating, misplaced flange_nut in the assembly
// guide's renders.
module flange_nut_in_place() {
    translate([0, screw_y, screw_z])
        rotate([0, 90, 0])
            translate([0, 0, -flange_nut_thickness / 2])
                flange_nut();
}

// Knurled turning knob, printed standalone and glued onto the screw's
// peg after assembly -- see dual_thread_screw() above for why it can't
// be fused onto the screw in one print. Socket sized with a small
// clearance over the peg for glue + an easy press-fit.
module knob() {
    difference() {
        cylinder(d = knob_dia, h = knob_h, $fn = 48);
        for (a = [0:30:359])
            rotate([0, 0, a])
                translate([knob_dia / 2 - 0.8, 0, -1])
                    cylinder(d = 2, h = knob_h + 2);
        translate([-(peg_size + 0.3) / 2, -(peg_size + 0.3) / 2, -1])
            cube([peg_size + 0.3, peg_size + 0.3, peg_len + 1.5]);
    }
}

// "full" preview only -- shows the knob glued onto the peg and the
// flange_nut threaded onto the screw's center, in their assembled
// positions (not fused -- both are still separate prints).
module dual_thread_screw_with_knob_preview() {
    dual_thread_screw();
    translate([0, screw_y, screw_z])
        rotate([0, 90, 0])
            translate([0, 0, peg_z0])
                knob();
    // Centered on the gap, not flush with one edge -- see
    // flange_nut_in_place() above for why this is factored out into its
    // own module rather than inlined here, and why an inline version
    // without the centering offset put the flange mostly outside
    // center_gap and into boss2's own footprint (harmless at a slim
    // clamp_screw_dia, a real ~40mm^3 collision at clamp_screw_dia=7).
    flange_nut_in_place();
}

module base_assembly() {
    connector();
    connector_bulk();
    arm();
    pivot_pin();
}

module clamp_center_assembly() {
    pivot_collar_top();
    pivot_collar_bottom();
    in_pivot_frame() center_bearing_and_rail();
}

module clamp_claw_right() {
    in_pivot_frame() slider_claw(claw_offset - slider_len / 2, false);
}

module clamp_claw_left() {
    in_pivot_frame() slider_claw(-claw_offset - slider_len / 2, true);
}

if (render_part == "connector") connector_plate_native();
else if (render_part == "base") base_assembly();
else if (render_part == "clamp_center") in_pivot_frame() center_bearing_and_rail();
else if (render_part == "collar_top") pivot_collar_top();
else if (render_part == "collar_bottom") pivot_collar_bottom();
else if (render_part == "clamp_claw_right") clamp_claw_right();
else if (render_part == "clamp_claw_left") clamp_claw_left();
else if (render_part == "screw") in_pivot_frame() dual_thread_screw();
else if (render_part == "knob") knob();
else if (render_part == "flange_nut") flange_nut();
else {
    base_assembly();
    color("SteelBlue") clamp_center_assembly();
    color("orange") clamp_claw_right();
    color("orange") clamp_claw_left();
    color("silver") in_pivot_frame() dual_thread_screw_with_knob_preview();
}
