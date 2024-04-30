echo("\n\n"); //just to make the output a bit clearer

include <prefs.scad>;

/* shared parameters */
wall_thickness = 1.2;
thin_wall_thickness = 0.75;
pin_hole_radius = 1.75 / 2;
pin_hole_clearance = 1.75; //The closest a pin hole should come to the edge of a large part
linkage_pin_hole_clearance = 1.75 / 2; // the same, but for a small part
string_hole_diameter = 1; //Sorry about mixing diameters and radii. I made a mistake early on and I'm tired
maximum_finger_bend_angle = 80;
elastic_hole_radius = 1;
gear_thickness = 6.5;
thin_linkage_thickness = 2;
really_small_clearance = 0.1;
printing_clearance = 5;

/* top linkage parameters */
top_linkage_clearance = 0.4;
top_linkage_thickness = pin_hole_radius*2 + linkage_pin_hole_clearance*2;
top_linkage_width = gear_thickness - top_linkage_clearance*2 + wall_thickness*4;
top_linkage_end_width = top_linkage_width - 2*top_linkage_clearance - 2*wall_thickness;
top_linkage_a_bit_closer_to_the_hand = -top_linkage_thickness;

/* gear parameters */
//chosen
// gear_inner_diameter = 7.5; // If you set this at 8.9. it'll match the original
gear_inner_diameter = pin_hole_radius*2 + pin_hole_clearance*2; // If you set this at 8.9. it'll match the original
gear_tooth_length = 1.5;
teeth_in_a_full_circle = 12; //the number of gears in a whole circle
rear_gear_number_of_teeth = 5;
front_gear_number_of_teeth = 5;
gear_cutoff_diameter = 7.5;
rear_gear_arm_thin_thickness = top_linkage_thickness/2;
// clearance_between_gears = 0.2;
gear_tolerance = 0;
gear_maximum_rotation = 90; // if you want to change this, then you've got some maths to do with the second joint rotation - see the module second_joint_rotation_tests
front_gear_slope_start = 13;
front_gear_slope_end = 22;
front_gear_rounding = 1.5; //Well, it's actually 'squaring'...
// I think I've calculated the angle of the gear teeth in a mathematically correct way,
// but that resulted in the finger not quite straightening. So this is an ad hoc correction for that.
// front_gear_correction_angle = 0.25;
front_gear_correction_angle = 0;
wedge_insertion_tolerance = 0.5;
//calculated
gear_extra_rotation = position_for == "comparison" ? -90 :
                            position_for == "visualisation" ? 90 - (gear_maximum_rotation / maximum_finger_bend_angle * finger_bend_angle) : 0;
echo(str("gears rotated by ", gear_extra_rotation));
gear_outer_diameter = gear_inner_diameter + 2/gear_tooth_length;
temp_rear_gear_height = -pin_hole_radius;

/* second joint parameters */
// chosen
second_joint_angle = 35;
// second_joint_extension_height = 14.7;
// second_joint_extension_width = 14;
hand_joint_raidus = 1.5;
second_joint_extension_corner_radius = 3;
second_joint_linear_clearance = 0.5;
second_joint_radial_clearance = 0.2;
second_joint_tab_length = 15;
second_joint_tab_width = hand_joint_raidus*4;
// I assume that the place where your tip thickness is measured
// is 3/4 of the way from the joint to the tip of a finger,
// or halfway if it's a thumb
tip_measurement_distance = this_is_a_thumb ? tip_length/2 : tip_length * 0.75;
//calculated
adjusted_finger_length = tip_length + extra_finger_length;
finger_tube_end_thickness = joint_thickness - (joint_thickness - tip_thickness) * adjusted_finger_length / tip_measurement_distance;
finger_tube_end_width = joint_width - (joint_width - tip_width) * adjusted_finger_length / tip_measurement_distance;
second_joint_sphere_height = finger_tube_end_thickness + wall_thickness*2;
second_joint_finger_tube_length = adjusted_finger_length + wall_thickness - second_joint_sphere_height/2;
// second_joint_tube_angle = 0;
// second_joint_height_adjustment = ((joint_thickness-tip_thickness)/2) * (second_joint_finger_tube_length - 4*knuckle_joint_raidus)/second_joint_finger_tube_length;
second_joint_height_adjustment = ((joint_thickness - finger_tube_end_thickness)/2);
// second_joint_tube_angle = atan((joint_thickness - tip_thickness)/(2*second_joint_finger_tube_length));
second_joint_tube_angle = atan(second_joint_height_adjustment/(second_joint_finger_tube_length));
second_joint_bottom_of_finger_tube = -second_joint_height_adjustment + joint_thickness/2 + wall_thickness;

/* first joint parameters */
//chosen
first_joint_angle = 48.5;
// first_joint_angle = 60;
knuckle_joint_raidus = 1.5;
base_straight_section_length = top_linkage_thickness*2;
string_guide_distance = joint_thickness*.25 ;
string_guide_radius = 2;
string_guide_angle = 20;
first_joint_height_offset = 0; // a little shift to stop the top linkage clashing with the finger tube
// first_joint_height_offset = wall_thickness; // a little shift to stop the top linkage clashing with the finger tube
first_joint_housing_overhang = top_linkage_thickness - pin_hole_clearance;
//calculated
first_joint_length_offset = first_joint_height_offset * tan(string_guide_angle);
join_with_second_joint = (wall_thickness -base_length) /2 - first_joint_length_offset;
first_joint_finger_length = base_length - join_with_second_joint;
// The cylinder's cross section is base_thickness x base_width at the hand end,
// then it's joint_thickness x joint_width at the joint.
// So we need to work out what it is at the end
first_joint_end_thickness = base_thickness - (first_joint_finger_length / base_length) * (base_thickness - joint_thickness);
// first_jfingerend_thickness = joint_thickness;
echo(str("first joint end thickness is ", first_joint_end_thickness));
first_joint_end_width = base_width - (first_joint_finger_length / base_length) * (base_width - joint_width);
first_joint_end_height_shift = second_joint_bottom_of_finger_tube - first_joint_end_thickness/2 - wall_thickness;
first_joint_linkage_housing_inner_displacement = first_joint_end_height_shift -first_joint_end_thickness/2 - wall_thickness - top_linkage_thickness - first_joint_height_offset;
first_joint_linkage_housing_outer_displacement = first_joint_linkage_housing_inner_displacement - thin_wall_thickness;
front_of_first_joint = -(first_joint_end_thickness/2 + wall_thickness + second_joint_height_adjustment) * tan(first_joint_angle);
first_joint_total_length = base_length - front_of_first_joint;
first_joint_pin_hole_position = [0, first_joint_linkage_housing_inner_displacement + top_linkage_thickness/2 + pin_hole_clearance - pin_hole_radius , front_of_first_joint + top_linkage_thickness/2];
// finger_bend_origin = [ knuckle_joint_raidus + second_joint_finger_tube_length - sqrt(pow(second_joint_finger_tube_length, 2) - pow(second_joint_height_adjustment, 2)), 0, second_joint_height_adjustment];

/* first extension parameters */
//chosen
clearance_between_extensions = 1;
first_extension_angle = 34.8;

/* long linkage paramters */
long_linkage_clearance = 5; // shave a bit off the length

/* front linkage parameters */
front_linkage_rear_section_length = 20;
front_linkage_thickness = pin_hole_radius*2 + pin_hole_clearance*2;
front_linkage_length = first_extension_length * 0.45;

/* housekeeping */
large_distance = 100;
tiny_distance = 0.01;
$fn = 30;


position_for_comparison_translations = [
    [base_width/2 + wall_thickness*2, 42, 0], // first joint
    [105, 62.5, 0], // top linkage
    [43.9, 14.5, 0], // second joint
    [56, 13, gear_thickness], // rear gear
    [24, 7.8, 0], // first extension
    [7, 49, gear_thickness/2], // front gear
    [0, 0, 0], // long_linkage
    [0, 22, 6.25], // front extension
    [0, 0, 0], // front linkage
];

position_for_comparison_rotations = [
    [-first_joint_angle, 0, 0], // first joint
    [0, 0, 180], // top linkage
    [-second_joint_angle, 0, 0], // second joint
    [180, 0, 35], // rear gear
    [90, 90-first_extension_angle, -90], // first extension
    [180, 0, 0], // front gear
    [0, 0, 0], // long_linkage
    [90, -90-first_extension_angle, -90], // front extension
    [0, 0, 0], // front linkage
];

position_for_printing_translations = [
    [0, 0, 0], // first joint
    [joint_width, joint_thickness/2, 0], // top linkage
    [base_width + wall_thickness + 0*printing_clearance, -finger_tube_end_thickness, 0], // second joint
    [-finger_tube_end_width/2, -second_joint_finger_tube_length/2 + printing_clearance + top_linkage_width/2, 0], // rear gear
    [joint_width*2 + printing_clearance, -finger_tube_end_thickness*1.5, 0], // first extension
    [0, -second_joint_finger_tube_length, gear_thickness/2], // front gear
    [second_joint_finger_tube_length/2, joint_thickness + top_linkage_width*2, thin_linkage_thickness/2], // long_linkage
    [joint_width*3 + printing_clearance - front_extension_length + finger_tube_end_width/2, -finger_tube_end_thickness*1.5, 0], // front extension
    [-second_joint_finger_tube_length - finger_tube_end_width + printing_clearance, top_linkage_width*2, 0], // front linkage
];

position_for_printing_rotations = [
    [-first_joint_angle, 0, 0], // first joint
    [0, 0, 0], // top linkage
    [-second_joint_angle, 0, 0], // second joint
    [0, 0, 40], // rear gear
    [0, 0, -90], // first extension
    [0, 0, 90], // front gear
    [0, 0, 90], // long_linkage
    [90, 0, -90], // front extension
    [0, 0, 0], // front linkage
];

position_for_origin_translations = [
    [0, 0, 0], // first joint
    [0, 0, 0], // top linkage
    [0, 0, 0], // second joint
    [0, 0, 0], // rear gear
    [0, 0, 0], // first extension
    [0, 0, 0], // front gear
    [0, 0, 0], // long_linkage
    [0, 0, 0], // front extension
    [0, 0, 0], // front linkage
];

position_for_origin_rotations = [
    [0, 0, 0], // first joint
    [0, 0, 0], // top linkage
    [0, 0, 0], // second joint linkage
    [0, 0, 0], // rear gear
    [0, 0, 0], // first extension
    [0, 0, 0], // front gear
    [0, 0, 0], // long_linkage
    [0, 0, 0], // front extension
    [0, 0, 0], // front linkage
];

// The dimensions for the visualisation are: sideways, backwards, up
position_for_visualisation_translations = [
    [0, 0, 0], // first joint
    [0, 0, 0], // top linkage
    [0, 0, 0], // second joint
    [0, gear_thickness/2, 0], // rear gear
    [0, 0, 0], // first extension
    [0, 0, 0], // front gear
    [0, 0, 0], // long_linkage
    [0, 0, 0], // front extension
    [0, 0, 0], // front linkage
];

position_for_visualisation_rotations = [
    [-90, 0, 90], // first joint
    [0, 0, 0], // top linkage
    [-90, 0, 90], // second joint
    [90, 0, 0], // rear gear
    [90, 0, 0], // first extension
    [90, 0, 0], // front gear
    [90, 0, 0], // long_linkage
    [90, 0, 0], // front extension
    [90, 0, 0], // front linkage
];

translations = (position_for == "comparison") ? position_for_comparison_translations :
    (position_for == "visualisation") ? position_for_visualisation_translations :
    (position_for == "printing")  ? position_for_printing_translations :  position_for_origin_translations;
rotations = (position_for == "comparison") ? position_for_comparison_rotations :
    (position_for == "visualisation") ? position_for_visualisation_rotations :
    (position_for == "printing") ? position_for_printing_rotations : position_for_origin_rotations;

if(position_for == "comparison"){
    translate([0, 0, -18.4]) {
        %import("AFE-Finger-T21-W25-L28-T20-W22-T15-W18-L58.STL");
        // translate([6.5, 4, 3.5]) {
        //     %import("AFE-Finger-T16.5-W18-L20.5-T15-W16-T11.5-W13.5-L39.5.STL");
        // }
    }
}


/*****************************************************************/

include <top_linkage.scad>;
include <gears.scad>;
include <first-joint.scad>;
include <second-joint.scad>;
include <first-extension.scad>;
include <long-linkage.scad>;
include <front-extension.scad>;
include <front-linkage.scad>;

if (print_first_joint || print_everything) first_joint();
if (print_second_joint || print_everything) second_joint();
if (print_top_linkage || print_everything) top_linkage();
if (print_rear_gear || print_everything) rear_gear();
if (print_first_extension || print_everything) first_extension();
if (print_front_gear || print_everything) front_gear();
if ((print_long_linkage || print_everything) && !this_is_a_thumb) long_linkage();
if ((print_front_extension || print_everything) && !this_is_a_thumb) front_extension();
if ((print_front_linkage || print_everything) && !this_is_a_thumb) front_linkage();

if(print_first_joint_length_tests) %first_joint_length_tests();
if (print_first_joint_test_holes) %first_joint_test_holes();
if(print_top_linkage_test_holes) %top_linkage_test_holes();
if(print_second_joint_length_tests) %second_joint_length_tests();
if(print_second_joint_rotation_tests) %second_joint_rotation_tests();
if(print_first_extension_tests) %first_extension_tests();
if(print_front_extension_tests) %front_extension_tests();
if (print_rear_gear_tests) rear_gear_tests();
if (print_rear_gear_sweep) %gear_sweep();

/******************
 * Common modules *
 ******************/

module horizontal_pin_hole() {
    rotate([0, 90, 0]) {
        cylinder(r=pin_hole_radius, h=large_distance, center=true);
    }
}

module smooth(r=3)
{
    $fn=30;
    offset(r=r)
    offset(r=-r)
    children();
}

module rotate_about_origin(origin, angles){
    translate(origin){
        rotate(angles){
            translate(-origin){
                children();
            }
        }
    }
}
