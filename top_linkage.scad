/* Right. Strap in if you're going to try and understand this.
* I bet there's a simpler way that real engineers do this,
* and I'm using far more variables than are necessary but here's what I'm doing:
* 
* The maximum angle you can bend your finger in one of these is about 80° and when it's there,
* I know where exactly where the front end of the linkage is.
* 
* Then when your finger is straight, I want the front of the linkage to sit at the same height,
* and from that I can calculate how far forward it is, and from that and the height of the gear,
* I can calculate the radius of the gear
*
* So with both ends calculated when it's straight, I can calculate the length of the linkage,
* and because I want it to sit on top of the finger tube, I know what angle it's at,
* so I can work out where the rear end of it will be, and that's where the first joint will need to rotate to.
*/

// these are unbent measurements, calculated from the first joint model itself
top_linkage_first_pin_hole_forward_distance = first_joint_pin_hole_position[2];
top_linkage_first_pin_hole_height = -first_joint_pin_hole_position[1];

// this is where I want the other end of the linkage to be when we're fully bent
top_linkage_basic_forward_distance = adjusted_finger_length + (finger_tube_end_thickness/2 + wall_thickness)* sin(second_joint_tube_angle);
top_linkage_second_pin_hole_forward_distance = top_linkage_basic_forward_distance - top_linkage_a_bit_closer_to_the_hand * cos(second_joint_tube_angle);
top_linkage_basic_height = position_for_visualisation_translations[2][2] + finger_tube_end_thickness/2 + wall_thickness + top_linkage_thickness/2; // I've doubled wall_thickness to give some clearance
top_linkage_second_pin_hole_height = top_linkage_basic_height + top_linkage_a_bit_closer_to_the_hand * sin(second_joint_tube_angle);

// The centre of the rear gear is at an arbitrary height, and because we're turning 90° it's at 45° to the pin
rear_gear_centre_position = [top_linkage_second_pin_hole_forward_distance + (top_linkage_second_pin_hole_height - temp_rear_gear_height), temp_rear_gear_height, 0];
rear_gear_radius = (top_linkage_second_pin_hole_height - temp_rear_gear_height) * sqrt(2);
function rotated_second_pin_forward_distance(angle) = rear_gear_centre_position[0] + rear_gear_radius * sin(-45+angle);
function rotated_second_pin_height(angle) = rear_gear_centre_position[1] + rear_gear_radius * cos(-45+angle);

// When your finger's straight, the first pin will line up with the first joint pin hole
top_linkage_unbent_first_pin_position = [-first_joint_pin_hole_position[2], 0, -first_joint_pin_hole_position[1]];
// which means we know how long the linkage is:
top_linkage_horizontal_length = rotated_second_pin_forward_distance(gear_maximum_rotation) - top_linkage_unbent_first_pin_position[0];
top_linkage_vertical_length = top_linkage_unbent_first_pin_position[2] - rotated_second_pin_height(gear_maximum_rotation);
top_linkage_length = sqrt(pow(top_linkage_horizontal_length,2) + pow(top_linkage_vertical_length,2) );
top_linkage_unbent_angle = atan( top_linkage_vertical_length / top_linkage_horizontal_length );
// This is to make it tidy, and this is how we'll calculate the other position of the linkage and therefore the rotation of the first joint:
top_linkage_fully_bent_angle = 2*second_joint_tube_angle;
echo(str("linkage angle goes from", top_linkage_unbent_angle , " to ", top_linkage_fully_bent_angle));
// This assumes that the angle changes linearly, which is wrong, so it'll only be right at the ends of the rotation
top_linkage_angle = top_linkage_unbent_angle + (finger_bend_angle / maximum_finger_bend_angle) * (top_linkage_fully_bent_angle - top_linkage_unbent_angle);

module top_linkage(){
    // These measurements work in the visualisation view, and they're what I'm using to calculate the length of the linkage
    // This angle is only right when the finger's straight or fully bent, but that's all I need.
    // And it's calculated a bit more explicitly when the finger's bent, because that's what I'm using to calculate things
    linkage_angle = position_for == "visualisation" ? top_linkage_angle : 0;
    extra_height_translation = position_for == "comparison" || position_for == "printing" ? top_linkage_thickness/2 :
                                           position_for == "visualisation" ? rotated_second_pin_height(gear_extra_rotation) : 0;
    extra_forward_translation = position_for == "visualisation" ? rotated_second_pin_forward_distance(gear_extra_rotation) :
                                position_for == "printing" ? top_linkage_length : 0;
    // prong_width = (top_linkage_width - gear_thickness - second_joint_linear_clearance)/2;
    translate(translations[1]){
        rotate(rotations[1]){
            rotate([0,0,0]){
                translate([extra_forward_translation, 0, extra_height_translation]) {
                    rotate([0, linkage_angle, 0]){
                        difference(){
                            union(){
                                // The forward end
                                translate([0, 0, 0]) {
                                    rotate([90, 0, 0]) {
                                        // #cylinder(r=top_linkage_thickness/2, h=prong_width);
                                        cylinder(r=top_linkage_thickness/2, h=top_linkage_width, center=true);
                                    }
                                }
                                // the main strip down the middle
                                translate([-top_linkage_length, -top_linkage_width/2, -top_linkage_thickness/2]) {
                                    cube([top_linkage_length, top_linkage_width, top_linkage_thickness]);
                                }
                                // The rear end
                                translate([-top_linkage_length, 0, 0]) {
                                    rotate([90, 0, 0]){
                                        cylinder(r=top_linkage_thickness/2, h=top_linkage_width, center=true);
                                    }
                                }
                            }
                            end_section_length = pin_hole_radius + pin_hole_clearance*3;
                            // the gap at the front end for the gear arm
                            translate([ top_linkage_thickness/2 - end_section_length, -gear_thickness/2 - top_linkage_clearance, -top_linkage_thickness/2 - tiny_distance]) {
                                cube([end_section_length, gear_thickness + top_linkage_clearance*2, top_linkage_thickness + tiny_distance*2]);
                            }
                            // the link between the main strip and the rear end
                            translate([-top_linkage_length - top_linkage_thickness/2, -top_linkage_width/2, -top_linkage_thickness/2 - tiny_distance]) {
                                cube([end_section_length + top_linkage_thickness/2, (top_linkage_width - gear_thickness)/2, top_linkage_thickness + tiny_distance*2]);
                            }
                            translate([-top_linkage_length - top_linkage_thickness/2, top_linkage_width/2 - (top_linkage_width - gear_thickness)/2, -top_linkage_thickness/2 - tiny_distance]) {
                                cube([end_section_length + top_linkage_thickness/2, (top_linkage_width - gear_thickness)/2, top_linkage_thickness + tiny_distance*2]);
                            }
                            top_linkage_holes();
                        }
                    }
                }
            }
        }
    }

}

module top_linkage_test_holes(){
    // a hole where we want the front of the linkage to be when your finger is bent
    translate([top_linkage_second_pin_hole_forward_distance, 0, top_linkage_second_pin_hole_height]) {
        rotate([90,0,0]){
            cylinder(d=pin_hole_radius*2, h=large_distance, center=true);
        }
    }
    // a hole that should line up with the rotation origin
    translate([rear_gear_centre_position[0], 0, rear_gear_centre_position[1]]) {
        rotate([90,0,0]){
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        // some holes that should line up with the second pin when you're rotated
        for (angle=[0:10:90]) {
            translate([rear_gear_radius * sin(-45+angle), 0, rear_gear_radius * cos(-45+angle)]) {
                rotate([90,0,0]){
                    cylinder(r=pin_hole_radius, h=large_distance, center=true);
                }
            }
        }
    }
    // the back of the linkage with a straight finger
    translate([top_linkage_second_pin_hole_forward_distance, 0, top_linkage_second_pin_hole_height]) {
        rotate([90,0,0]){
            #cylinder(d=pin_hole_radius*2, h=large_distance, center=true);
        }
        rotate([0, top_linkage_fully_bent_angle, 0]){
            translate([-top_linkage_length, 0, 0]) {
                rotate([90,0,0]){
                    #cylinder(d=pin_hole_radius*2, h=large_distance, center=true);
                }
            }
        }
    }
    
}

module top_linkage_holes() {
    rotate([90, 0, 0]){
        cylinder(r=pin_hole_radius, h=large_distance, center=true);
    }
    translate([-top_linkage_length, 0, 0]) {
        rotate([90, 0, 0]){
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        
    }
}
