front_linkage_width = first_extension_end_width - 4*wall_thickness;
front_linkage_height = top_linkage_thickness;
front_linkage_rectangle_length =  0*front_linkage_height*tan(first_extension_angle) + front_linkage_length/2;
front_linkage_trim_length = front_linkage_rectangle_length/4; // the distance that the front linkage goes into the first extension
// front_linkage_trim_length = 0;

module front_linkage(){
    translate(translations[8]) {
        rotate(rotations[8]){
            difference(){
                front_linkage_solid();
                front_linkage_holes();
            }
        }
    }
}

module front_linkage_solid(){
    translate([0, 0, position_for == "printing" ? front_linkage_width/2 : 0]) {
        hull(){
            translate(front_extension_first_rotation_origin + front_extension_second_rotation_origin + [0,0,0]) {
                cylinder(r=top_linkage_thickness/2, h=front_linkage_width, center=true);
            }
            translate([ -front_linkage_trim_length + front_gear_centre_position[0] + first_extension_start + first_extension_length, front_linkage_trim_length * sin(first_extension_top_angle) + second_joint_extension_bottom + first_extension_end_height, 0]) {
                front_linkage_wedge(tiny_distance, tiny_distance);
            }
        }
        translate([ - front_linkage_trim_length + front_gear_centre_position[0] + first_extension_start + first_extension_length, second_joint_extension_bottom + first_extension_end_height + top_linkage_thickness*sin(first_extension_top_angle), 0]) {
            front_linkage_wedge();
        }
        
    }
}

module front_linkage_holes(){
    translate(front_extension_first_rotation_origin + front_extension_second_rotation_origin + [0,0,0]) {
        cylinder(r=pin_hole_radius, h=large_distance, center=true);
    }
    translate([front_gear_centre_position[0] + first_extension_start + first_extension_length, second_joint_extension_bottom + first_extension_end_height, 0]) {
        rotate([0, 0, -first_extension_top_angle]){
            translate([-front_linkage_rectangle_length, -top_linkage_thickness/2, 0]) {
                cylinder(r=pin_hole_radius, h=large_distance, center=true);
                translate([front_linkage_rectangle_length/2, 0, 0]) {
                    cylinder(r=pin_hole_radius, h=large_distance, center=true);
                }
            }
        }
    }
}

module front_linkage_wedge(wedge_length = front_linkage_length - front_linkage_trim_length, rectangle_length = front_linkage_rectangle_length - front_linkage_trim_length) {
    // If you put in a small distance for each of those lengths, you'll get a sliver that you can make hulls with
        rotate([0, 0, -first_extension_top_angle]) {
            linear_extrude(front_linkage_width, center=true){
                polygon(points =    [[0, 0],
                                    [-wedge_length, 0],
                                    [-rectangle_length, -front_linkage_height],
                                    [0, -front_linkage_height]
                                    ]);
            }
        }
}
