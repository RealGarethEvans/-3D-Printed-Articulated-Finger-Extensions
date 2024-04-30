/* The part that goes on the back of your hand for the fingers to attach to */

length = 60;
width = 40;
thickness = 1.6;

strap_width = 12;
strap_thickness = 3;

hole_clearance = 2; // The distance between any hole and he edge of the model
knot_hole_diameter = 5;
elastic_hole_diameter = 2;
gap_width = 0.25;
slot_length = 1;

number_of_fingers = 5;
start_angle = -90;

tiny_distance = 0.01;
large_distance = 200;

$fn = 100;

difference(){
    minkowski() {
        plate();
        sphere(r=thickness, $fn=20);
    }
    strap_holes();
    finger_holes();
    translate([-large_distance/2, -large_distance/2, -large_distance]) {
        cube([large_distance, large_distance, large_distance]);
    }
}

module plate(){
    translate([-width/2, 0, 0]) {
        cube([width, length - width/2, tiny_distance]);
        
    }
    translate([0, length - width/2, 0]) {
        cylinder(d=width, h=tiny_distance);
    }
}

module strap_holes(){
    translate([0, hole_clearance, -large_distance/2]){
        strap_hole();
        mirror([1, 0, 0]) {
            strap_hole();
        }
        
    }
}

module strap_hole(){
            translate([(hole_clearance - width/2), 0, 0]){
                cube([strap_thickness, strap_width, large_distance]);
            }

}

module finger_holes() {
    angle_increment = 2*start_angle/(number_of_fingers - 1);
    translate([0, length - width/2, 0]){
        for (i=[0:number_of_fingers-1]) {
            angle = start_angle - i*angle_increment;
            forward_distance = i==0 ? (width/2 - hole_clearance) - length + strap_width*2  : (width/2 - hole_clearance) * cos(angle);
            translate([(width/2 - hole_clearance - knot_hole_diameter/2) * sin(angle), forward_distance, 0]) {
                rotate([0, 0, -angle/2])
                #finger_hole();
                
            }
        }
    }
    
}

module finger_hole(){
    $fn = 30;
    translate([0, -elastic_hole_diameter/2, -large_distance/2]){
        cylinder(d=elastic_hole_diameter, h=large_distance);
        translate([0, -knot_hole_diameter/2 - elastic_hole_diameter/2 - slot_length , 0]) {
            cylinder(d=knot_hole_diameter, h=large_distance);
        }
        // slot_length = slot_length;
        translate([-gap_width/2,  -elastic_hole_diameter/2 - knot_hole_diameter/2 - slot_length, 0]) {
            cube([gap_width, elastic_hole_diameter/2 + knot_hole_diameter/2 + slot_length, large_distance]);
        }
    }
}