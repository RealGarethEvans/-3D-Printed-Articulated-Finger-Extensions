/* This is built in the visualisation view, with the orign in the middle of the front gear, to make rotations easier */

visualisation_rotation = position_for == "visualisation" ? -90+gear_extra_rotation: 0;
echo(str("first extension rotated by ", visualisation_rotation));
first_extension_start = -second_joint_extension_bottom + clearance_between_extensions;
first_extension_start_top = second_joint_extension_top + pin_hole_radius;
first_extension_end_height = second_joint_extension_height - first_extension_height_reduction;
first_extension_end_width = second_joint_extension_width - first_extension_width_reduction;
first_extension_top_angle = atan((  first_extension_start_top - second_joint_extension_bottom - first_extension_end_height) / (first_extension_length)  );
first_extension_printing_rotation = position_for == "printing" ? [90, 90-first_extension_angle, 0] : [0,0,0];
// first_extension_printing_rotation = [0,0,0];
// first_extension_printing_translation = [-front_gear_centre_position[0] - first_extension_length - first_extension_start, - first_extension_start_top + wall_thickness, 0];
first_extension_printing_translation = [-front_gear_centre_position[0] - first_extension_start - first_extension_length, -second_joint_extension_bottom - first_extension_end_height, 0];


module first_extension() {
    echo(str("First extension translation: ", translations[4]));
    translate(translations[4]) {
        rotate(rotations[4]){
            rotate(first_extension_printing_rotation){
                translate([front_gear_centre_position[0], 0, 0]) {
                    rotate([0, 0, visualisation_rotation]){
                        translate(position_for == "printing" || position_for == "comparison" ? first_extension_printing_translation : [0,0,0]) {
                            difference(){
                                if(this_is_a_thumb){
                                    translate([-first_extension_length, 0, 0]) {
                                        front_extension_solid();
                                    }
                                } else{
                                    first_extension_solid();
                                }
                                first_extension_void();
                                first_extension_holes();
                            }
                        }
                    }
                }
            }
        }
    }
}

module first_extension_solid(){
    difference(){
        hull(){
            big_radius = 3;
            small_radius =1;
            translate([first_extension_start, 0, 0]) {
                for (i=[-1,1]) {
                    translate([0, second_joint_extension_bottom + big_radius, i*(-second_joint_extension_width/2 + big_radius)]) {
                        rotate([0,90,0]){
                            cylinder(r=big_radius, h=tiny_distance);
                        }
                    }
                }
                for (i=[-1,1]) {
                    translate([0, first_extension_start_top - big_radius, i*(-second_joint_extension_width/2 + big_radius)]) {
                        rotate([0,90,0]){
                            cylinder(r=big_radius, h=tiny_distance);
                        }
                    }
                }
                
            }
            translate([first_extension_start + first_extension_length, 0, 0]) {
                for (i=[-1,1]) {
                    translate([0, second_joint_extension_bottom + small_radius, i*(-first_extension_end_width/2 + small_radius)]) {
                        rotate([0,90,0]){
                            cylinder(r=small_radius, h=tiny_distance);
                        }
                    }
                }
                for (i=[-1,1]) {
                    translate([0, second_joint_extension_bottom + first_extension_end_height - small_radius, i*(-first_extension_end_width/2 + small_radius)]) {
                        rotate([0,90,0]){
                            cylinder(r=small_radius, h=tiny_distance);
                        }
                    }
                }
            }
        }
        // cut off the top corner at the back
        translate([second_joint_extension_middle_pin_position[2], 0, -second_joint_extension_width/2]) {
            rotate([0, 0, -second_joint_angle]){
                translate([-large_distance, 0, 0]) {
                    cube([clearance_between_extensions + large_distance, second_joint_extension_height, second_joint_extension_width]);
                }
            }
        }
        // and the diagonal slice at the front end
        translate([first_extension_start + first_extension_length, +first_extension_end_height + second_joint_extension_bottom, 0]) {
            rotate([0, 0, -first_extension_angle]){
                translate([0, -first_extension_end_height*sqrt(2), -first_extension_end_width]) {
                    cube([first_extension_end_height/sqrt(2), first_extension_end_height*sqrt(2), first_extension_end_width*2]);
                }
            }
        }
    }
    // front_linkage();
}
module first_extension_void(){
    // The hole for the front gear
    rotate([0, 0, 90]){
        printing_translation = [0, -front_gear_centre_position[0], -gear_thickness];
        extra_translation =  [0, 0, -gear_thickness/2];
        // this is a very hacky way of getting some tolerance
        for (i=[-1,1]) {
            for (j=[-1,1]) {
                translate( extra_translation + [j*second_joint_linear_clearance, 0, i*second_joint_linear_clearance]) {
                    front_gear_arm(already_positioned=true);
                }
            }
        }
        
    }
    // The gap down the middle for the long linkage
    cutout_width = thin_linkage_thickness + top_linkage_clearance*2;
    if(!this_is_a_thumb){
    linear_extrude(cutout_width, center=true){
        polygon(points=[
            [first_extension_start, second_joint_extension_bottom + wall_thickness],
            [first_extension_start, first_extension_start_top],
            [first_extension_start + first_extension_length/2, (first_extension_start_top +  first_extension_end_height + second_joint_extension_bottom)/2],
            [first_extension_start + first_extension_length/2, (first_extension_start_top +  first_extension_end_height + second_joint_extension_bottom)/2 - wall_thickness],
            [first_extension_start + first_extension_length -wall_thickness * cos(first_extension_angle), first_extension_end_height + second_joint_extension_bottom - wall_thickness],
            [first_extension_start + first_extension_length -first_extension_end_height * cos(first_joint_angle), second_joint_extension_bottom],
            [first_extension_start + first_extension_length/2 - long_linkage_clearance, second_joint_extension_bottom],
            [first_extension_start + first_extension_length/2 - long_linkage_clearance, second_joint_extension_bottom + wall_thickness]]);
        }

        // The gap for the front linkage, again with some tolerance hacked in
        translate([first_extension_start + first_extension_length, second_joint_extension_bottom + first_extension_end_height, 0]) {
            for (i=[-1,1]) {
                translate([0, 0, i*second_joint_linear_clearance]) {
                    front_linkage_wedge();
                    translate([-second_joint_linear_clearance, -second_joint_linear_clearance, 0]) {
                        front_linkage_wedge();
                    }
                }
            }
        }
    }
}

// rotate([90,0,0])
// #front_linkage_holes();

module first_extension_holes(){
    rotate([0, 0, 90]){
        translate( [0, 0, 0]) {
            front_gear_holes(already_positioned=true);
        }
    }
    if(!this_is_a_thumb){
        translate( - translations[4] + [-front_gear_centre_position[0], 0, 0]) {
        // #translate( first_extension_printing_translation + [first_extension_length,0,0,]) {
            front_linkage_holes();
        }
    }
}

module first_extension_tests() {
    translate([front_gear_centre_position[0] + first_extension_length,-7, second_joint_extension_bottom]) {
        // cube([10, 10, first_extension_end_height]);
    }
    translate([front_gear_centre_position[0] + first_extension_start + first_extension_length, second_joint_extension_bottom + first_extension_end_height, 0]) {
        #cube([10,10,10]);
    }
}