second_joint_extension_length = front_gear_centre_position[0] - adjusted_finger_length + gear_inner_diameter/2 + gear_tooth_length + pin_hole_radius ;
second_joint_finger_tube_horizontal_length = sqrt( pow(adjusted_finger_length,2) - pow(joint_thickness - finger_tube_end_thickness, 2));
second_joint_total_length = second_joint_extension_length + second_joint_finger_tube_horizontal_length + wall_thickness;
echo(str("Second Joint is ", second_joint_total_length, " long"));

second_joint_extension_rear_pin_position = [0, -rear_gear_centre_position[1], second_joint_total_length - hand_joint_raidus/2 - rear_gear_centre_position[0]];
second_joint_extension_middle_pin_position = [0, -front_gear_centre_position[1], second_joint_total_length - hand_joint_raidus/2 - front_gear_centre_position[0]];
second_joint_extension_top = gear_inner_diameter/2  + gear_tooth_length;
second_joint_extension_bottom = rear_gear_centre_position[1] - gear_inner_diameter/2 - gear_tooth_length - wall_thickness ;
second_joint_extension_height = second_joint_extension_top -second_joint_extension_bottom;
// second_joint_extension_width = gear_thickness + second_joint_linear_clearance + 4*wall_thickness; // the wall thickness is doubled to help with bed adhesion
second_joint_extension_width = finger_tube_end_width - 2*wall_thickness; // the wall thickness is doubled to help with bed adhesion
echo(str("second joint extension height is", second_joint_extension_height));
echo(str("second joint extension width is", second_joint_extension_width));
second_joint_front_hole_translation = [0, -second_joint_extension_top + pin_hole_radius, 0];
second_joint_visualisation_shift = position_for=="visualisation" ? [second_joint_total_length - hand_joint_raidus/2, 0, 0] : [0,0,0];

module second_joint() {
    translate(translations[2] + second_joint_visualisation_shift) {
        rotate(rotations[2]){
            difference(){
                second_joint_solid();
                second_joint_void();
                second_joint_holes();
            }
        }
    }
}


module second_joint_solid(){
    difference() {
        union(){
            second_joint_extension_polygon = [
                            [-second_joint_extension_width/2, -second_joint_extension_top],
                            [-second_joint_extension_width/2, -second_joint_extension_bottom],
                            [second_joint_extension_width/2, -second_joint_extension_bottom],
                            [second_joint_extension_width/2, -second_joint_extension_top]
                        ];
            // the rectangular section that contains the mechanism
            translate([0, 0, -large_distance]) {
                linear_extrude(large_distance + second_joint_extension_length -second_joint_sphere_height/4){
                    smooth(second_joint_extension_corner_radius){
                        polygon(points=second_joint_extension_polygon);
                    }
                }
                
            }
            // A little bit extra to tidy it up. TODO: could be far tidier
            hull(){
                translate([0, 0, second_joint_extension_length - second_joint_sphere_height/4]) {
                    linear_extrude(tiny_distance){
                        smooth(second_joint_extension_corner_radius){
                            polygon(points=second_joint_extension_polygon);
                        }
                    }
                    
                }
                translate([0, 0, second_joint_extension_length]) {
                    difference(){
                        cylinder(d=finger_tube_end_thickness + wall_thickness*2, h=1, center=false);
                        translate([-finger_tube_end_width/2 - wall_thickness, -finger_tube_end_thickness, 0]) {
                            cube([finger_tube_end_width + 2*wall_thickness, finger_tube_end_thickness, finger_tube_end_thickness]);
                        }
                    }
                }
            }
            // the tube itself. The hemispheriod at the end isn't included in length calculations in order to provide some extra tolerance
            finger_tube(my_wall_thickness=wall_thickness);
            // the protrusion at the front for the long linkage
            if(!this_is_a_thumb){
                hull() {
                    translate(second_joint_front_hole_translation) {
                        rotate([0, 90, 0]) {
                            cylinder(d=top_linkage_thickness, h=second_joint_extension_width, center=true);
                        }
                    }
                    // translate([-second_joint_extension_width/2, -second_joint_extension_height/2, 0]) {
                    translate(second_joint_front_hole_translation) {
                        translate([-second_joint_extension_width/2, 0, -large_distance]) {
                            cube([second_joint_extension_width, (pin_hole_radius + pin_hole_clearance)*2, large_distance]);
                        }
                    }
                }
            }
            // the tabs nearest the hand, for the string to attach to
            translate([0, -finger_bend_origin[2], second_joint_total_length - finger_bend_origin[0]]) {
                rotate([second_joint_tube_angle, 0, 0]){
                    translate([0, 0, 0 ]) {
                        rotate([0, 90, 0]){
                            translate([knuckle_joint_raidus, 0, 0]) {
                                cylinder(r=knuckle_joint_raidus, h=joint_width+wall_thickness*3, center=true);
                                linear_extrude(joint_width+wall_thickness*3, center=true){
                                    polygon(points=[
                                        [0, -knuckle_joint_raidus],
                                        [knuckle_joint_raidus*2, -knuckle_joint_raidus],
                                        [knuckle_joint_raidus*3, -knuckle_joint_raidus*2],
                                        [knuckle_joint_raidus*3 + second_joint_tab_length/2, -second_joint_tab_width/2],
                                        [knuckle_joint_raidus*3 + second_joint_tab_length/2, second_joint_tab_width/2],
                                        [knuckle_joint_raidus*3, knuckle_joint_raidus*2],
                                        [knuckle_joint_raidus*2, knuckle_joint_raidus],
                                        [0, knuckle_joint_raidus],
                                    ]);
                                }
                            }
                            chamfer_height = second_joint_tab_length*.5;
                            hull() {
                                linear_extrude(joint_width+wall_thickness*3, center=true){
                                    polygon(points=[
                                        [knuckle_joint_raidus*3 + second_joint_tab_length/2, -knuckle_joint_raidus*2],
                                        [knuckle_joint_raidus*3 + second_joint_tab_length/2 + tiny_distance, -second_joint_tab_width/2],
                                        [knuckle_joint_raidus*3 + second_joint_tab_length/2 + tiny_distance, second_joint_tab_width/2],
                                        [knuckle_joint_raidus*3 + second_joint_tab_length/2, knuckle_joint_raidus*2],
                                    ]);
                                }
                                translate([second_joint_tab_length*1.5, 0, 0]) {
                                    difference(){
                                        rotate([0,-90,0]){
                                            cylinder(d=joint_width, h=tiny_distance);
                                        }
                                        translate([-chamfer_height*.5, second_joint_tab_width/2, -large_distance/2]) {
                                            cube([chamfer_height*.5, large_distance, large_distance]);
                                        }
                                        translate([-chamfer_height*.5, -large_distance - second_joint_tab_width/2, -large_distance/2]) {
                                            cube([chamfer_height*.5, large_distance, large_distance]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        second_joint_trim();
    }
}

module second_joint_void(){
    cutout_width = gear_thickness + second_joint_linear_clearance*2;
    translate([0, 0, wall_thickness]) {
        finger_tube(my_wall_thickness=0);
    }
    // the gap in the extension for the gears
    translate(second_joint_extension_rear_pin_position) {
        rotate([0, 90, 0]) {
            cylinder(d=gear_inner_diameter + gear_tooth_length*2 + second_joint_radial_clearance*2, h=cutout_width, center=true);
        }
    }
    // the square gap inside and in the top wall
    difference(){
        translate([-cutout_width/2, -second_joint_extension_top -tiny_distance, 0]) {
            cube([cutout_width, second_joint_extension_top - second_joint_extension_bottom - wall_thickness + tiny_distance, second_joint_extension_length]);
        }
        translate([0, 0, 0]) {
            finger_tube(my_wall_thickness=wall_thickness);
        }
        // bring back just a little bit of the lid to make the end stronger
        translate([-cutout_width/2, - second_joint_extension_top, top_linkage_thickness/2 + top_linkage_clearance]) {
            cube([cutout_width, wall_thickness, wall_thickness]);
        }
        // bring back some material because otherwise we'd need a support
        difference(){
            translate([0, 0, second_joint_extension_length - second_joint_sphere_height/2 + wall_thickness]) {
                rotate([second_joint_angle, 0, 0]){
                    translate([-cutout_width/2, 0, -wall_thickness*1.95]) {
                        cube([cutout_width, large_distance, second_joint_extension_length]);
                        
                    }
                }
            }
            translate([-cutout_width/2, -large_distance, -large_distance/2]) {
                cube([cutout_width, large_distance, large_distance]);
            }
        }
    }
    // the gap at the bottom
    translate([-cutout_width/2, -second_joint_extension_top + (pin_hole_clearance+pin_hole_radius), 0]) {
        cube([cutout_width, second_joint_extension_height - (pin_hole_clearance+pin_hole_radius)  + tiny_distance, second_joint_extension_middle_pin_position[2] + gear_inner_diameter]);
    }
    // the gap for the thin linkage to go through
    translate([-thin_linkage_thickness/2 - second_joint_linear_clearance/2, -second_joint_extension_height, -large_distance]) {
        cube([second_joint_linear_clearance + thin_linkage_thickness, second_joint_extension_height, large_distance + pin_hole_radius + pin_hole_clearance]);
    }
    // the space between the tabs nearest your hand
    translate([-joint_thickness/2, -joint_thickness, second_joint_total_length - knuckle_joint_raidus*4]) {
        cube([joint_thickness, joint_thickness,10]);
    }
}

module second_joint_holes(){
    // The pin holes are ordered starting away fron the hand
    if(!this_is_a_thumb){
        translate(second_joint_front_hole_translation) {
            horizontal_pin_hole();
        }
    }
    translate(second_joint_extension_middle_pin_position) {
        horizontal_pin_hole();
    }
    translate(second_joint_extension_rear_pin_position) {
        horizontal_pin_hole();
    }
    // The string hole
    for (i=[-1,1]) {
        translate([i*(joint_width/2 + wall_thickness*.75), 0, 0]){
            rotate([second_joint_tube_angle,0,0]){
                cylinder(d=string_hole_diameter, h=large_distance);
            }
        }
    }
    
}

module second_joint_trim() {
    /* the angle where the joint meets the third joint */
    rotate([second_joint_angle, 0, 0]){
        translate([-large_distance/2, -large_distance, -large_distance]) {
            cube([large_distance, large_distance*2, large_distance]);
        }
    }
    // the rounded shape at the top
    translate([0, -finger_bend_origin[2], second_joint_total_length - finger_bend_origin[0]]){
        rotate([second_joint_tube_angle,0,0]){
            translate([-large_distance/2, 0, -knuckle_joint_raidus*3]){
                translate([0, knuckle_joint_raidus, 0]){
                    rotate([-first_joint_angle, 0, 0]){
                        cube([large_distance, large_distance, large_distance]);
                    }
                }
                translate([0, -knuckle_joint_raidus, 0]){
                    rotate([90 + first_joint_angle - second_joint_tube_angle, 0, 0]){
                        cube([large_distance, large_distance, large_distance]);
                    }
                }
                // the offcuts that the above cubes leave
                translate([0, knuckle_joint_raidus, 0]) {
                    cube([large_distance,large_distance,large_distance]);
                }
                translate([0, -large_distance - knuckle_joint_raidus, 0]) {
                    cube([large_distance,large_distance,large_distance]);
                }
            }
        }
    }
}

module finger_tube(my_wall_thickness){
    // The cylindrical bit where most of your real finger goes
    // second_joint_sphere_height = tip_thickness + my_wall_thickness*0;
    translate([0, 0, second_joint_extension_length + wall_thickness - my_wall_thickness]) {
        rotate([second_joint_tube_angle, 0, 0]) {
            scale([finger_tube_end_width + my_wall_thickness*2, finger_tube_end_thickness + my_wall_thickness*2, second_joint_sphere_height]) {
                sphere(d=1); 
            }
            hull(){
                translate([0, 0, 0]) {
                    scale([finger_tube_end_width + my_wall_thickness*2, finger_tube_end_thickness + my_wall_thickness*2, tiny_distance]) {
                        cylinder(d=1, h=1); 
                    }
                }
                // translate([0, 0, adjusted_finger_length + my_wall_thickness - second_joint_sphere_height/2]) {
                translate([0, 0, second_joint_finger_tube_length ]) {
                    scale([joint_width + my_wall_thickness*2, joint_thickness + my_wall_thickness*2, tiny_distance]) {
                        cylinder(d=1, h=1); 
                    }
                }
            }
        }
        
    }
}

module second_joint_rotation_tests(){
    second_joint_bend_radius = sqrt(pow(second_joint_extension_middle_pin_position[2],2) + pow(second_joint_front_hole_translation[1], 2));
    translate(translations[2] + second_joint_visualisation_shift) {
        rotate(rotations[2]){
            rotate([0, 0, 0]){
                // in/out, down, forward
                translate([0, 0, second_joint_extension_middle_pin_position[2]]){
                    rotate([0,90,0]){
                        cylinder(r=second_joint_bend_radius, h=large_distance, center=true);
                    }
                    second_joint_unbent_front_hole_angle = asin( second_joint_extension_middle_pin_position[2] / second_joint_bend_radius);
                    echo(str("angle between gear centre and front hole is ", second_joint_unbent_front_hole_angle));
                    // This hole lines up with the front hole, by rotating it
                    rotate([ second_joint_unbent_front_hole_angle,0,0]){
                        translate([0, -second_joint_bend_radius, 0]) {
                            rotate([0,90,0]){
                                cylinder(r=pin_hole_radius, h=large_distance, center=true);
                            }
                        }
                    }
                    // This hole lines up with the rotated front hole
                    rotate([ second_joint_unbent_front_hole_angle-90,0,0]){
                        translate([0, -second_joint_bend_radius, 0]) {
                            rotate([0,90,0]){
                                cylinder(r=pin_hole_radius, h=large_distance, center=true);
                            }
                        }
                    }
                    // This hole lines up with the front hole, by translating it
                    translate([0, second_joint_front_hole_translation[1], -second_joint_extension_middle_pin_position[2]]) {
                            rotate([0,90,0]){
                                cylinder(r=pin_hole_radius, h=large_distance, center=true);
                            }
                            /* this hole should match the one below, but it's done just by calculating the lateral movements
                             * And the last component of that translation is the horizontal movement of the long linkage
                             * and we'll use it to place the centre of rotation of the front extension
                            */
                            translate([0, -second_joint_front_hole_translation[1] - second_joint_extension_middle_pin_position[2], second_joint_extension_middle_pin_position[2] - second_joint_front_hole_translation[1]]){
                                rotate([0,90,0]){
                                    cylinder(r=pin_hole_radius, h=large_distance, center=true);
                                }
                            }
                    }
                    // This lines up with the rotated front hole, just by swapping the x and y components
                    // And this is where we commit to a 90° rotation for the joints
                    translate([0, -second_joint_extension_middle_pin_position[2], -second_joint_front_hole_translation[1]]) {
                            rotate([0,90,0]){
                                cylinder(r=pin_hole_radius, h=large_distance, center=true);
                            }
                    }
                }
                translate([0, second_joint_front_hole_translation[1], 0]) {
                    rotate([0,90,0]){
                        // cylinder(r=pin_hole_radius, h=large_distance, center=true);
                    }
                }
            }
            // Bonus - a hole that sits on the origin in the visualisation view
            translate([0, 0, second_joint_visualisation_shift[0]]) {
                rotate([0,90,0]){
                    #cylinder(r=pin_hole_radius, h=large_distance, center=true);
                }
            }
        }
    }
}

module second_joint_length_tests(){
    translate([10, 0, second_joint_extension_length]) {
        rotate([second_joint_tube_angle, 0, 0]){
            translate([0, -wall_thickness, 0]){
                translate([10, 0, 0]) {
                        cylinder(d=tip_thickness, h=1);
                    }
                translate([10, 0, adjusted_finger_length+wall_thickness + .01]){
                    cylinder(d=joint_thickness, h=1);
                }
            }
        }
    }
    translate([0, 10, 0]) {
        cube([knuckle_joint_raidus*4,5, second_joint_extension_length]);
    }
    translate([0, 20, 0]) {
        cube([5,5, second_joint_total_length]);
    }
    translate([0, 25, second_joint_extension_length]) {
        cube([5,5, second_joint_finger_tube_length]);
    }
}
