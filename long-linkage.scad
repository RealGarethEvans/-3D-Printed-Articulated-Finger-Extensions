/* this is the long linkage that goes from the front of the second joint, through the first extension and controls the last extension
 * it's built in the visualisation view, and with the finger fully bent */

long_linkage_start_of_first_extension = front_gear_centre_position[0] + first_extension_start; //because we've got a different origin to the first extension module
long_linkage_end_of_first_extension = long_linkage_start_of_first_extension + first_extension_length;
long_linkage_middle_corner_height = wall_thickness - top_linkage_thickness/2;
// long_linkage_first_corner_position = [second_joint_total_length + first_joint_visualisation_shift_forwards + hand_joint_raidus/2, -second_joint_front_hole_translation[1], 0];
long_linkage_first_corner_position = [second_joint_total_length - hand_joint_raidus/2, -second_joint_front_hole_translation[1], 0];
// The other points are calculated relative to the first. The second and third are calculated with a straight finger
long_linkage_section_length = (2*long_linkage_start_of_first_extension + long_linkage_end_of_first_extension)/3 - long_linkage_first_corner_position[0];
// TODO: the height on this is a little bit wrong. Adjust it for the slope of the top
long_linkage_second_corner_position = [long_linkage_section_length, long_linkage_middle_corner_height, 0]; // a third of the way along the extension
// The fourth point is calculated with a bent finger
long_linkage_bottom_position = second_joint_extension_bottom + top_linkage_thickness/2 - long_linkage_first_corner_position[1];
long_linkage_fourth_corner_forward_distance = second_joint_extension_height + wall_thickness - pin_hole_clearance + pin_hole_radius // this gets us to the bottom of the joint
                                + clearance_between_extensions + first_extension_length //level with the top end of the first extension
                                - first_extension_end_height * tan(first_extension_angle) // level with the bottom endo of the first extension
                                + pin_hole_radius + clearance_between_extensions*tan(first_extension_angle) + pin_hole_clearance // just into the front extension
                                + pin_hole_clearance*tan(first_extension_angle) // and properly inside the front extension
                                ;
long_linkage_fourth_corner_position = [long_linkage_fourth_corner_forward_distance, long_linkage_bottom_position, 0];
// long_linkage_third_corner_position = [long_linkage_second_corner_position[0] + first_extension_length/3, long_linkage_bottom_position, 0];
long_linkage_third_corner_position = [long_linkage_fourth_corner_position[0] - long_linkage_section_length, long_linkage_bottom_position - long_linkage_middle_corner_height, 0];

long_linkage_test_rotation = position_for == "visualisation" ? 0 : 0;
long_linkage_printing_translation = position_for == "printing" ? [-long_linkage_start_of_first_extension,0,0] : [0,0,0];

module long_linkage(){
        translate(translations[6]) {
            rotate(rotations[6]){
                translate(long_linkage_printing_translation){
                    translate(long_linkage_first_corner_position){
                        rotate([0, 0, -90 + gear_extra_rotation - long_linkage_test_rotation]){
                            difference(){
                                union(){
                                    hull() {
                                        cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                                        translate(long_linkage_second_corner_position) {
                                            cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                                        }
                                    }
                                    hull(){
                                        translate(long_linkage_second_corner_position) {
                                            cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                                        }
                                        translate(long_linkage_third_corner_position){
                                            cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                                        }
                                    }
                                    hull(){
                                        translate(long_linkage_third_corner_position){
                                            cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                                        }
                                        translate(long_linkage_fourth_corner_position) {
                                            cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                                        }
                                    }
                                }
                                cylinder(r=pin_hole_radius, h=large_distance, center=true);
                                translate(long_linkage_second_corner_position){
                                    // cylinder(r=pin_hole_radius, h=large_distance, center=true);
                                }
                                translate(long_linkage_third_corner_position){
                                    // cylinder(r=pin_hole_radius, h=large_distance, center=true);
                                }
                                translate(long_linkage_fourth_corner_position){
                                    cylinder(r=pin_hole_radius, h=large_distance, center=true);
                                }
                            }
                        }
                    }

                }
                // the linkage
                // #translate(long_linkage_first_corner_position){
                //     rotate([0, 0, -90 + gear_extra_rotation - long_linkage_test_rotation]){
                //         difference(){
                //             union(){
                //                 hull() {
                //                     cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                //                     translate(long_linkage_second_corner_position) {
                //                         cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                //                     }
                //                 }
                //                 hull(){
                //                     translate(long_linkage_second_corner_position) {
                //                         cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                //                     }
                //                     translate(long_linkage_third_corner_position){
                //                         cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                //                     }
                //                 }
                //                 hull(){
                //                     translate(long_linkage_third_corner_position){
                //                         cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                //                     }
                //                     translate(long_linkage_fourth_corner_position) {
                //                         cylinder(d=top_linkage_thickness, h=thin_linkage_thickness, center=true);
                //                     }
                //                 }
                //             }
                //             cylinder(r=pin_hole_radius, h=large_distance, center=true);
                //             translate(long_linkage_second_corner_position){
                //                 // cylinder(r=pin_hole_radius, h=large_distance, center=true);
                //             }
                //             translate(long_linkage_third_corner_position){
                //                 // cylinder(r=pin_hole_radius, h=large_distance, center=true);
                //             }
                //             translate(long_linkage_fourth_corner_position){
                //                 cylinder(r=pin_hole_radius, h=large_distance, center=true);
                //             }
                //         }
                //     }
                // }
            }
        }
}