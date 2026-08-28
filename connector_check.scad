bulk_margin=3; bulk_depth=6;
module connector() { rotate([90,0,0]) translate([5.3,-1,2.55]) import("reference/connector_only.stl"); }
module usb_slot_clearance() { translate([-7.5,-3.55,-17.9]) cube([12.7, 3.55+bulk_depth+10, 8.6]); }
module connector_bulk() { difference() { translate([-12.4-bulk_margin, 3.55, -27-bulk_margin]) cube([24.8+2*bulk_margin, bulk_depth, 27+2*bulk_margin]); usb_slot_clearance(); } }
connector();
color("orange",0.6) connector_bulk();
