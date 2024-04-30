include <bezier.scad>;

function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

// In the top linkage file, we calculated the two extreme points where the end of the linkage could be.
// To get the centre of the rear gear, we go halfway between these two points, and the same distance down
// rear_gear_arm_length_component = (top_linkage_rotated_forward_distance(0) - top_linkage_second_pin_hole_forward_distance)/2;
rear_gear_arm_length_component = 10;
top_linkage_rear_pin_position = [
    top_linkage_second_pin_hole_forward_distance, top_linkage_second_pin_hole_height
    ];
// rear_gear_centre_position = [top_linkage_second_pin_hole_forward_distance + rear_gear_arm_length_component, top_linkage_second_pin_hole_height - rear_gear_arm_length_component, 0];
// rear_gear_centre_position is calculated in the top linkage file
// rear_gear_centre_position = [top_linkage_second_pin_hole_forward_distance + rear_gear_arm_length_component, top_linkage_second_pin_hole_height - rear_gear_arm_length_component, 0];
echo(str("rear gear centred at ", rear_gear_centre_position));

gear_arm_points = [
    top_linkage_rear_pin_position,
    [rear_gear_centre_position[0] - rear_gear_arm_length_component*.7, top_linkage_rear_pin_position[1]*1],
    [rear_gear_centre_position[0] - rear_gear_arm_length_component*.45, top_linkage_rear_pin_position[1]*0.75],
    rear_gear_centre_position + [-gear_inner_diameter/2 + rear_gear_arm_thin_thickness/4, -gear_inner_diameter/4, 0],
];
points_to_plot = detailed ? b_curv( gear_arm_points) : gear_arm_points;

// The centre of the front gear lines up with the centre of the extension. We calculate its position from that and its distance fron the rear gear
distance_between_gears = gear_inner_diameter + gear_tooth_length;
forward_distance_between_gears = sqrt( abs(pow(distance_between_gears, 2) - pow(rear_gear_centre_position[1], 2) ));
echo(str("Gears are ", forward_distance_between_gears, " apart"));
front_gear_centre_position = [rear_gear_centre_position[0] + forward_distance_between_gears, 0, -gear_thickness/2];
// We need to rotate the front gear a little bit so that the teeth mesh properly
angle_between_gears = -atan(rear_gear_centre_position[1] / forward_distance_between_gears);
// And this is the same, but with 'teeth' as the unit
echo(str("Angle between gears is ", angle_between_gears));
angle_in_teeth = angle_between_gears * teeth_in_a_full_circle / 360;
echo(str("which is equivalent to ", angle_in_teeth, " teeth"));

module rear_gear(test_rotation = 0) {
    translate(translations[3]) {
        rotate(rotations[3]){
            translate(rear_gear_centre_position) rotate([0, 0, -gear_extra_rotation - test_rotation]) translate(-rear_gear_centre_position){
                translate(rear_gear_centre_position) {
                    gear_wheel(number_of_teeth=rear_gear_number_of_teeth, start_tooth = 10.5);
                }
                // the arm
                difference() {
                    number_of_points = len(points_to_plot);
                    for (i = [0:number_of_points-1]) {
                        width_factor = i / (number_of_points-1);
                        cylinder_diameter = rear_gear_arm_thin_thickness + width_factor * (top_linkage_thickness - rear_gear_arm_thin_thickness);
                        translate(points_to_plot[i]){
                            cylinder(d=cylinder_diameter, h=gear_thickness);
                        }
                    }
                    translate(top_linkage_rear_pin_position) {
                        cylinder(r=pin_hole_radius, h=large_distance, center=true);
                        
                    }
                    translate(rear_gear_centre_position) {
                        cylinder(r=pin_hole_radius, h=large_distance, center=true);
                    }
                }
            }
        }
    }
}

front_gear_arm_height = -gear_inner_diameter/2 - gear_tooth_length;
module front_gear(){
    difference() {
        union(){
            front_gear_movements(){
                gear_wheel(number_of_teeth=front_gear_number_of_teeth, start_tooth = 2 + angle_in_teeth*2, extra_rotation=front_gear_correction_angle);
                front_gear_arm(already_positioned=true);
            }
        }
        front_gear_holes();
    }
}

module front_gear_arm(already_positioned=false){
    front_gear_movements(already_positioned){
        linear_extrude(gear_thickness){
            polygon(points = [
                    [front_gear_arm_height, -gear_inner_diameter - gear_tooth_length + pin_hole_radius*2],
                    [0, pin_hole_radius*2],
                    [0.5*gear_inner_diameter/sqrt(2), -0.5*gear_inner_diameter/sqrt(2)],
                    [0, -gear_inner_diameter],
                    [0, -front_gear_slope_start],
                    [front_gear_arm_height + front_gear_rounding, -front_gear_slope_end],
                    [front_gear_arm_height, -front_gear_slope_end]
                ]);
        };
    }
}
        
module front_gear_holes(already_positioned = false){
    first_pin_hole_x = -gear_inner_diameter/4 - gear_tooth_length/2;
    first_pin_hole_y = -first_extension_start - pin_hole_radius - pin_hole_clearance;
    second_pin_hole_x = linkage_pin_hole_clearance - gear_inner_diameter/2 - gear_tooth_length/2;
    second_pin_hole_y = pin_hole_radius + (-front_gear_slope_start - front_gear_slope_end)/2;
    front_gear_movements(already_positioned){
        cylinder(r=pin_hole_radius, h=large_distance, center=true);
        translate([first_pin_hole_x, first_pin_hole_y, 0]) {
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
        translate([second_pin_hole_x, second_pin_hole_y, 0]) {
            cylinder(r=pin_hole_radius, h=large_distance, center=true);
        }
    }
}

module front_gear_movements(already_positioned = false) {
    actual_rotations = already_positioned ? [0,0,0] : rotations[5];
    echo(str("rotating by: ", actual_rotations));
    translate(already_positioned ? [0, 0, 0] : translations[5]) {
        rotate(actual_rotations){
            translate(already_positioned ? [0,0,0] : front_gear_centre_position ) rotate([0, 0, already_positioned ? 0 : gear_extra_rotation]) {
                children();
            }
        }
    }
}

module gear_wheel(number_of_teeth, start_tooth=0, extra_rotation=0){
    /* I've rolled my own gear because using a library made the rendering slow */ 
    gear_inner_circumference = gear_inner_diameter * 3.14;
    whole_tooth_width = gear_inner_circumference/teeth_in_a_full_circle;
    echo(str("one tooth is ", whole_tooth_width, " wide"));
    // tooth_base_width = 1.1;
    // tooth_halfway_width = 1.15;
    // tooth_distance_to_widest_point = 1.15;
    tooth_base_width = whole_tooth_width* 0.56;
    tooth_halfway_width = whole_tooth_width* 0.59;
    tooth_distance_to_widest_point = gear_tooth_length * 0.76;
    bezier_fs = 1; // very rough, but renders in a reasonable time
    
    function get_points(i) = [[-1.5,i*tooth_base_width/2],[tooth_distance_to_widest_point,i*tooth_halfway_width],[gear_tooth_length,0]];
    curve_points = concat (b_curv(get_points(1), fs=bezier_fs), reverse(b_curv( get_points(-1), fs=bezier_fs)), [[-1,0]]);
    for (i=[1:number_of_teeth]) {
        rotate([0,0,(i + start_tooth)*360/teeth_in_a_full_circle + extra_rotation]){
            translate([gear_inner_diameter/2 - gear_tolerance, 0, 0]) {
                linear_extrude(gear_thickness){
                    polygon(points = curve_points);
                }
            }

        }
    }
    
    difference(){
        // %cylinder(d=gear_inner_diameter + gear_tooth_length, h=large_distance, center=true);
        cylinder(d=gear_inner_diameter, h=gear_thickness);
        cylinder(r=pin_hole_radius, h=large_distance, center=true);
        difference() {
            translate([0, 0, -tiny_distance]) {
                cylinder(d=large_distance, h=gear_thickness+ 2*tiny_distance);
                
            }
            cylinder(d=gear_cutoff_diameter, h=gear_thickness);
            rotate([0, 0, -90]) {
                translate([-large_distance/2, -large_distance, 0]) {
                    cube([large_distance, large_distance, gear_thickness]);
                }
            }
            
        }
    }
}

module rear_gear_tests(){
    translate(translations[3]) {
        translate([rear_gear_centre_position[0], 0, rear_gear_centre_position[1]]) {
            rotate([90,0,0]){
                #cylinder(r=pin_hole_radius, h=large_distance, center=true);
            }
        }
        translate([top_linkage_rear_pin_position[0], 0, top_linkage_rear_pin_position[1]]) {
            rotate([90,0,0]){
                #cylinder(r=pin_hole_radius, h=large_distance, center=true);
            }
        }
        echo(str("rear gear arm radius is ", sqrt(pow(top_linkage_rear_pin_position[0] - rear_gear_centre_position[0], 2) + pow(top_linkage_rear_pin_position[1] - rear_gear_centre_position[1],2)) ));
    }
}

module gear_sweep(){
    for (angle=[0:10:90]) {
        rear_gear(test_rotation=angle);
    }
}