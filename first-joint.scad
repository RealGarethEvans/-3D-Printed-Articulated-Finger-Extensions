/**************************************************
 * The first joint (ie the one nearest your hand) *
 **************************************************/

// The following isn't quite right, but I think it's within the bounds of actual tolerances
finger_bend_rotation = [ 0, position_for == "visualisation" ? -finger_bend_angle: 0, 0];
// first_joint_extra_rotation = second_joint_tube_angle/2;
first_joint_extra_rotation = -0;

// Sorry about the proliferation of variables with long names —
// It could be expressed more succinctly, but this is me showing my working
first_joint_bent_pin_forward_distance = top_linkage_second_pin_hole_forward_distance - top_linkage_length*cos(top_linkage_fully_bent_angle);
first_joint_bent_pin_height = top_linkage_second_pin_hole_height + top_linkage_length*sin(top_linkage_fully_bent_angle);

first_joint_horizontal_distance_between_pin_positions = -first_joint_bent_pin_forward_distance - first_joint_pin_hole_position[2];
first_joint_vertical_distance_between_pin_positions = first_joint_bent_pin_height + first_joint_pin_hole_position[1];
first_joint_distance_between_pin_positions = sqrt( pow(first_joint_vertical_distance_between_pin_positions, 2) + pow(first_joint_horizontal_distance_between_pin_positions, 2));
first_joint_angle_between_pin_positions = atan(first_joint_vertical_distance_between_pin_positions / first_joint_horizontal_distance_between_pin_positions);
first_joint_angle_from_pin_to_origin = 90 - (maximum_finger_bend_angle/2) - first_joint_angle_between_pin_positions;
finger_bend_radius = first_joint_distance_between_pin_positions / ( 2* sin(maximum_finger_bend_angle/2));
finger_bend_origin = [ -first_joint_pin_hole_position[2] - finger_bend_radius*cos(first_joint_angle_from_pin_to_origin), 0, -first_joint_pin_hole_position[1] - finger_bend_radius*sin(first_joint_angle_from_pin_to_origin)];

module first_joint() {
    echo(str("First joint translation: ", translations[0]));
    echo(str("First joint rotation: ", rotations[0]));
    echo(str("Variable = ", finger_bend_origin));
    // translate(finger_bend_origin) {
    //     %rotate([90,0,0]){
    //         cylinder(d=1, h=large_distance, center=true);
    //     }
    // }
    translate(finger_bend_origin) rotate(finger_bend_rotation) translate(-finger_bend_origin){
        translate(translations[0]) {
            rotate(rotations[0] + [first_joint_extra_rotation, 0, 0]){
                difference(){
                    first_joint_solid();
                    first_joint_void();
                    first_joint_holes();
                }
            }
        }
    }
}

module first_joint_solid(){
    // the tube itself
    difference() {
        hull(){
            translate([0, second_joint_bottom_of_finger_tube - base_thickness/2 - wall_thickness - first_joint_height_offset, base_length]) {
                resize([base_width + 2*wall_thickness, base_thickness + 2*wall_thickness, tiny_distance]){
                    cylinder(d=1, h=1);
                }
            }
            translate([0, first_joint_end_height_shift - first_joint_height_offset, front_of_first_joint *2]) {
                resize([first_joint_end_width + 2*wall_thickness, first_joint_end_thickness + 2*wall_thickness, tiny_distance]){
                    cylinder(d=1, h=1);
                }
            }
        }
        first_joint_trim();
    }
    //The raised section that attaches to the top linkage
    hull() {
        top_protrusion = 1.75;
        translate([ 0, first_joint_linkage_housing_outer_displacement, front_of_first_joint]) {
            linear_extrude(base_straight_section_length){
                polygon(points=[[-top_linkage_width/2, wall_thickness], [-top_linkage_width/2 + wall_thickness, 0], [top_linkage_width/2 - wall_thickness, 0], [top_linkage_width/2, wall_thickness], [top_linkage_width/2, base_thickness/2 + thin_wall_thickness], [-top_linkage_width/2,base_thickness/2 + thin_wall_thickness]]);
            }
        }
        translate([-0, -wall_thickness-base_thickness/2 , base_length*.6]) {
            linear_extrude(tiny_distance){
                polygon(points=[[-top_linkage_width/2, wall_thickness], [-top_linkage_width/2 + wall_thickness, 0], [top_linkage_width/2 - wall_thickness, 0], [top_linkage_width/2, wall_thickness], [top_linkage_width/2, base_thickness/2 + thin_wall_thickness], [-top_linkage_width/2,base_thickness/2 + thin_wall_thickness]]);
            }
        }
    }
    // The protrusions on the side for the string holes
    hull(){
        translate([0, -finger_bend_origin[2], -finger_bend_origin[0]]) {
        // translate([0, -knuckle_joint_raidus, knuckle_joint_raidus]) {
            rotate([0, 90, 0]) {
                cylinder(r=string_guide_radius*2, h=joint_width + wall_thickness*3, center=true);
            }
            translate([0, -string_guide_distance+string_guide_radius/2, string_guide_distance-string_guide_radius/2]) {
                rotate([0, 90, 0]) {
                    cylinder(r=string_guide_radius, h=joint_thickness + wall_thickness*0, center=true);
                }
            }
        }
    }
}

module first_joint_void() {
    /* the inside of the first joint — you should be able to subtract this from any model you like */
    // the inside of the tube
    hull(){
        translate([0, second_joint_bottom_of_finger_tube - base_thickness/2 - wall_thickness - first_joint_height_offset, base_length]) {
            resize([base_width, base_thickness, tiny_distance]){
                cylinder(d=1, h=1);
            }
        }
        translate([0, second_joint_bottom_of_finger_tube - first_joint_end_thickness/2 - wall_thickness - first_joint_height_offset, front_of_first_joint*2]) {
            resize([first_joint_end_width, first_joint_end_thickness, tiny_distance]){
                cylinder(d=1, h=1);
            }
        }
    }
    // the inside of the square section where the top linkage sits
    translate([ -gear_thickness/2 - top_linkage_clearance, first_joint_linkage_housing_inner_displacement, front_of_first_joint - tiny_distance - first_joint_housing_overhang]) {
        cube([ gear_thickness + top_linkage_clearance*2, base_thickness, base_straight_section_length + tiny_distance]);
    }
    // we trim the void as well as the solid to make life easier for remixers
    first_joint_trim();
}

module first_joint_trim(){
    /* cutoffs that are shared between the solid joint and its void */
    /* the angle where the joint meets the second joint */
    translate([0, -first_joint_height_offset, -first_joint_length_offset]) {
        rotate([first_joint_angle, 0, 0]){
            translate([-large_distance/2, -large_distance, -large_distance]) {
                cube([large_distance, large_distance*2, large_distance]);
            }
        }
        
    }
    // the gap where finger meets hand
    rotate([0,-90,0]){
        hull() {
            translate([base_length+tiny_distance, second_joint_bottom_of_finger_tube, -large_distance/2]) {
                cylinder(r=tiny_distance, h=large_distance);   
                translate([0, -base_thickness - wall_thickness*2, 0]) {
                    cylinder(r=tiny_distance, h=large_distance);   
                }
                translate([ hand_joint_raidus + (-base_thickness/2 + wall_thickness)*sqrt(2), first_joint_height_offset - (base_thickness/2 + wall_thickness), 0]) {
                    cylinder(r=hand_joint_raidus, h=large_distance);   
                }
            }
        }
    }
    /* The gap where the joint meets the second joint */
    cube_size = knuckle_joint_raidus*2.5;
    translate([-large_distance/2, -finger_bend_origin[2], -cube_size - finger_bend_origin[0]]) {
        minkowski() {
            cube([large_distance, cube_size, cube_size]);
            sphere(r=knuckle_joint_raidus);
        }
    }
}

module first_joint_holes(){
    translate(first_joint_pin_hole_position) {
        horizontal_pin_hole();
    }
    // the holes for the elastic
    rotate([90, 0, 0]) {
        for (i=[-1,1]) {
            translate([i*base_width/6, base_length - elastic_hole_radius*3, 0]) {
                cylinder(r=elastic_hole_radius, h=large_distance);
            }
        }
    }
    // the holes for the string TODO: Does this scale properly?
    for (i=[-1,1]) {
        translate([i*(joint_width/2 + wall_thickness*.75), -finger_bend_origin[2], -finger_bend_origin[0]]) {
            rotate([first_joint_angle, i*-string_guide_angle, 0]) {
                cylinder(d=string_hole_diameter, h=large_distance, center=false);
            }
            
        }
    }
}

module first_joint_test_holes(){
    // the pin hole when your finger's straight
    translate([-first_joint_pin_hole_position[2], 0, -first_joint_pin_hole_position[1]]){
        rotate([90, 0, 0]) {
            #cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        // a stick between the two pin hole positions
        rotate([0, first_joint_angle_between_pin_positions, 0]) {
            translate([-first_joint_horizontal_distance_between_pin_positions, -10, -pin_hole_radius]) {
                cube([first_joint_horizontal_distance_between_pin_positions, 20, pin_hole_radius*2]);
            }
        }
        // a stick between the unbent pin hole position and the rotation origin
        rotate([0, -first_joint_angle_from_pin_to_origin, 0]) {
            translate([-finger_bend_radius, -large_distance/2, -pin_hole_radius]) {
                cube([finger_bend_radius, large_distance, pin_hole_radius*2]);
            }
        }
        
    }
    // The pin hole when your finger's bent
    translate([first_joint_bent_pin_forward_distance, 0, first_joint_bent_pin_height]){
        rotate([90, 0, 0]) {
            #cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        // a stick between the bent pin hole position and the rotation origin
        rotate([0, first_joint_angle_between_pin_positions + (180 - maximum_finger_bend_angle)/2, 0]) {
            translate([0, -large_distance/2, -pin_hole_radius]) {
                cube([finger_bend_radius, large_distance, pin_hole_radius*2]);
            }
        }
    }
    translate(finger_bend_origin + [0, 0, 0]) {
        rotate([90, 0, 0]) {
            // #cylinder(r=0.1, h=large_distance, center=true);
            cylinder(r=knuckle_joint_raidus, h=large_distance, center=true);
        }
    }
    rotate([90, 0, 0]) {
        // #cylinder(r=knuckle_joint_raidus*2, h=large_distance, center=true);
    }
}

module first_joint_length_tests(){
    translate([0, 0, front_of_first_joint]) {
        cube([10,10,first_joint_total_length]);
    }
}
