/* The frontmost extension. Built in the visualisation view */

front_extension_bottom_hole_position = long_linkage_first_corner_position + long_linkage_fourth_corner_position + [0,0,0]; // heehee I said bottom hole
long_linkage_backwards_movement = second_joint_extension_middle_pin_position[2] - second_joint_front_hole_translation[1]; // to see how this is calculated, look at the rotation tests in the second joint file
echo(str("linkage backwards movement is ", long_linkage_backwards_movement));
front_extension_top_hole_position = front_extension_bottom_hole_position + [-long_linkage_backwards_movement / 2, long_linkage_backwards_movement / 2, 0];

front_extension_first_rotation_origin = [front_gear_centre_position[0], 0, 0];
front_extension_second_rotation_origin = front_extension_top_hole_position - [front_gear_centre_position[0],0,0]; //relative to the front gear origin

front_extension_end_height = first_extension_end_height - (second_joint_extension_height - first_extension_end_height);
front_linkage_width = first_extension_end_width - 2*wall_thickness;

front_extension_printing_translation = [front_extension_first_rotation_origin[0] - first_extension_length - second_joint_total_length - clearance_between_extensions , 0, 0];
front_extension_printing_rotation = position_for == "printing" ? [0, 0, 90+first_extension_angle] : [0,0,0];

test_rotation = 0;

module front_extension(){
    translate(translations[7]){
        translate(front_extension_first_rotation_origin) {
            rotate(rotations[7]){
                rotate([0, 0, visualisation_rotation]){
                    translate(front_extension_second_rotation_origin) rotate([0, 0, visualisation_rotation] + [0, 0, -test_rotation]) translate(-front_extension_second_rotation_origin){
                        rotate(front_extension_printing_rotation){
                            translate(position_for == "printing" || position_for == "comparison" ? front_extension_printing_translation : [0,0,0]) {
                                difference(){
                                    front_extension_solid();
                                    front_extension_void();
                                    front_extension_holes();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module front_extension_solid() {
    start_width = this_is_a_thumb ? second_joint_extension_width : first_extension_end_width;
    difference(){
        translate([first_extension_length + clearance_between_extensions, second_joint_extension_bottom, -start_width/2]) {
            hull(){
                cube([tiny_distance, first_extension_end_height, start_width]);
                translate([front_extension_length - front_extension_end_height/2, 0, 0]) {
                    cube([tiny_distance, front_extension_end_height, first_extension_end_width]);
                }
            }
            translate([front_extension_length - front_extension_end_height/2, front_extension_end_height/2, 0]) {
                rotate([0, 0, 0]){
                    cylinder(d=front_extension_end_height, h=first_extension_end_width, center=false);
                }
            }
        }
        translate([-front_extension_first_rotation_origin[0] + first_extension_length + second_joint_total_length + clearance_between_extensions, 0, 0]){
            rotate([0, 0, -first_extension_angle]){
                translate([-large_distance, -large_distance/2, -large_distance/2]) {
                    cube([large_distance, large_distance, large_distance]);
                }
            }
        }
        translate(front_extension_bottom_hole_position + [-front_gear_centre_position[0], 0, 0]){
            rotate([0, 0, 180-first_extension_angle]){
                translate([-large_distance/2, top_linkage_thickness/2 + top_linkage_clearance, -large_distance/2]) {
                    cube([large_distance, large_distance, large_distance]);
                }
            }
        }
    }
}

module front_extension_void() {
    cube_size=first_extension_end_height; // close enough
    translate([-cube_size + front_extension_top_hole_position[0] - front_gear_centre_position[0] + top_linkage_thickness/2 + top_linkage_clearance, second_joint_extension_bottom, -front_linkage_width/2- second_joint_linear_clearance]) {
        cube([cube_size, first_extension_end_height-wall_thickness, front_linkage_width + second_joint_linear_clearance*2]);
    }
    translate([-cube_size + front_extension_bottom_hole_position[0] - front_gear_centre_position[0] + top_linkage_thickness/2 + top_linkage_clearance, second_joint_extension_bottom, -thin_linkage_thickness/2- top_linkage_clearance]) {
        cube([cube_size, first_extension_end_height-wall_thickness, thin_linkage_thickness + second_joint_linear_clearance*2]);
    }
    rotate([-90,0,0])
    for (i=[-1:1]) {
        translate([-front_gear_centre_position[0], i * second_joint_linear_clearance, really_small_clearance]) {
            front_linkage();
        }
    }
    
}

module front_extension_holes() {
    // The long linkage
    translate([-front_gear_centre_position[0], 0, 0]){
        translate(front_extension_bottom_hole_position){
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        // The centre of rotation
        translate(front_extension_top_hole_position){
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
    }
}


module front_extension_tests(){
    rotate([90, 0, 0]){
        translate(front_extension_bottom_hole_position + [0,0,0]){
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        translate(front_extension_top_hole_position + [0,0,0]){
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        translate(-front_extension_second_rotation_origin + [0,0,0]){
            // cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
    }
}
