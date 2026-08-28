// Standalone connector plate -- the piece that slides into the GameSir
// Cyclone-family controller's mount. Rebuilt natively in OpenSCAD from
// measurements taken off a real, watertight reference mesh
// (reference/connector_only.stl), rather than imported as an opaque mesh,
// so it can be freely extended/modified later without guessing what's
// safe to touch.
//
// Tab-clip size/position/profile, the plate footprint, and the USB-C slot
// are measured to match the reference mesh (these mate with real
// hardware); the corner fillets and the small alignment nub are close
// visual approximations, not exact -- they carry no mechanical function.
//
// The tabs are NOT plain posts -- they're snap-fit barbs: a base flush
// with the plate surface (no riser gap), blending immediately into a
// constant-width neck that slides through the controller's narrow lower
// opening, then a head that flares out in the wider pocket beyond.
//
// Print flat as-is: bottom face on the bed, tabs pointing up, no supports.

plate_w = 24.8; plate_l = 27; plate_t = 2.11; plate_corner_r = 2;
tab_y = -10.0; tab_l = 8.0;

// Depth budget: base to head tip, starting flush at the plate surface
// (Z = plate_top_z) -- confirmed by hand-sketch (option D) that the neck
// must start with zero gap/recess below it, not sit atop a tall separate
// base riser like the first cut did.
plate_top_z = -4.0; plate_bottom_z = -6.11;
tab_z0 = plate_top_z;
// Depth budget arrived at through printed test-fit iteration (8mm guessed
// -> 4.5mm measured -> 3.5mm, still ~1mm too deep -> 4mm confirmed best
// via an A/B print test against a 3.5mm variant).
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

$fn = 48;

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

connector_plate_native();
