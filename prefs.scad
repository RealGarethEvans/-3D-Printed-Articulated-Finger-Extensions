/* All the parameters that you'd call user prefs are here, mainly to avoid cluttering the git history */

/***********************************************************************
 * Finger measurements. These include all the tolerance you're getting *
 ***********************************************************************/

// These measurements correspond to the file AFE-Finger-T21-W25-L28-T20-W22-T15-W18-L58.STL
// base_thickness = 21;
// base_width = 25;
// base_length = 28;
// joint_thickness = 20;
// joint_width = 22;
// tip_thickness = 15;
// tip_width = 18;
// tip_length = 58;
// this_is_a_thumb = false;

// My left index finger, more comfortable on the right
// base_thickness = 20;
// base_width = 22;
// base_length = 28;
// joint_thickness = 17.5;
// joint_width = 22;
// tip_thickness = 13.5;
// tip_width = 18;
// tip_length = 44;
// this_is_a_thumb = false;

// My left ring finger, more comfortable on the right
// base_thickness = 20;
// base_width = 21;
// base_length = 25;
// joint_thickness = 20;
// joint_width = 20;
// tip_thickness = 15;
// tip_width = 18;
// tip_length = 45.5;
// this_is_a_thumb = false;

// My left middle finger, more comfortable on the right
// base_thickness = 21.5;
// base_width = 22;
// base_length = 28;
// joint_thickness = 21.5;
// joint_width = 21.5;
// tip_thickness = 16;
// tip_width = 18.5;
// tip_length = 47.5;
// this_is_a_thumb = false;

// My scrawny left little finger; the tip thickness needs to be taken down
// base_thickness = 13.5;
// base_width = 21;
// base_length = 17;
// joint_thickness = 17.5;
// joint_width = 17.5;
// tip_thickness = 14;
// tip_width = 16;
// tip_length = 35.5;
// this_is_a_thumb = false;

// My right little finger
base_thickness = 18.5;
base_width = 20;
base_length = 19.5;
joint_thickness = 18;
joint_width = 19;
tip_thickness = 14;
tip_width = 17;
tip_length = 36.5;
this_is_a_thumb = false;


// My left thumb
// base_thickness = 21;
// base_width = 24;
// base_length = 19;
// joint_thickness = 20.5;
// joint_width = 23.5;
// tip_thickness = 17;
// tip_width = 22.5;
// tip_length = 34.5;
// this_is_a_thumb = true;

/****************************************************
 * Other measurements that you might want to change *
 ****************************************************/
extra_finger_length = 12; // set this to at least 5
first_extension_length = 48;
first_extension_width_reduction = 4; // how much thinner the end of the first extension will be than the start
first_extension_height_reduction = 1;
front_extension_length = 70;



/******************************
 * What do you want to print? *
 ******************************/
// print_everything = true; // This will override any of the choices below
print_everything = false;

print_first_joint = false;
print_second_joint = false;
print_top_linkage = false;
print_rear_gear = false;
print_front_gear = false;
// print_first_extension = false;
print_long_linkage = false;
print_front_linkage = false;
print_front_extension = false;

// print_first_joint = true;
// print_second_joint = true;
// print_top_linkage = true;
// print_rear_gear = true;
// print_front_gear = true;
print_first_extension = true;
// print_long_linkage = true;
// print_front_linkage = true;
// print_front_extension = true;

print_first_joint_length_tests = false;
print_first_joint_test_holes = false;
print_top_linkage_test_holes = false;
print_second_joint_length_tests = false;
print_second_joint_rotation_tests = false;
print_first_extension_tests = false;
print_front_extension_tests = false;
print_rear_gear_tests = false;
print_rear_gear_sweep = false;


/************************************
 * and how do you want to print it? *
 ************************************/
// position_for = "comparison";
// position_for = "visualisation";
position_for = "printing";
// position_for = "origin";
finger_bend_angle = 0;
detailed = true;


