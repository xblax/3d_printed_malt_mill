/* 
 * 3D Printed Malt Mill
 * Designed by xblax: https://github.com/xblax/3d_printed_malt_mill
 * Licensed GPL v3 
 */

use <libs/knurledFinish/knurledFinishLib_v2_1.scad>
use <libs/threads/thread_profile.scad>

$fn=100;
$eps=0.01;

// roller dimensions
$roller_width=40;
$roller_diameter=40;
$roller_min_dist=0.25;   // minimum distance between the two rollers
$roller_adj_range=2.75; // adjustable range of second roller

$roller_side_clearance=1.5;
$roller_head_clearance=1.5;
$roller_top_clearance=1.5;
$roller_bottom_clearance=5; // note: 5mm needed due to gear size

// frame walls
$frame_head_width=9; // thick enough for 7mm bearing inset
$frame_side_width=6;
$frame_top_width=0.5;

// calculated values
$frame_inner_width=$roller_diameter*2+$roller_side_clearance*2+$roller_min_dist+$roller_adj_range;
$frame_inner_depth=$roller_width+$roller_head_clearance*2;
$frame_inner_height=$roller_diameter+$roller_bottom_clearance+$roller_top_clearance;

$frame_width=$frame_inner_width+$frame_side_width*2;
$frame_height=$frame_inner_height+$frame_top_width;
$frame_depth=$frame_inner_depth+$frame_head_width*2;

$primary_roller_x=$frame_side_width+$roller_side_clearance+$roller_diameter/2;
$secondary_roller_x=$frame_side_width+$roller_side_clearance+$roller_diameter/2*3+$roller_min_dist;
$roller_z=$roller_bottom_clearance+$roller_diameter/2;

// mouting holes
$mounting_hole_diameter = 2.5; // to be used with 3mm screws
$mounting_hole_depth = 20; // should not collide with adjusment mechanism
$mounting_hole_inset = $frame_head_width/2;
$attachment_hole_depth = 15;


// top opening of frame
$top_opening_roller_overlap=2;
$top_opening_width=$frame_inner_width;
$top_opening_depth=$frame_inner_depth - 2 * $top_opening_roller_overlap;

// roller knurling
$knurl_wd=5;
$knurl_hg=5;
$knurl_dp=3;
$knurl_e_smooth=1;
$knurl_s_smooth=70;
$knurl_cylinder_od=$roller_diameter-($knurl_dp*(100-$knurl_s_smooth)/100); // calculate cylinder diameter (total diamater minus knurling)

// roller M8 axis parameters
$roller_axis_through_hole=8.4;
$insert_nut_size=13.2;
$insert_nut_thickness=6.25;
$insert_nut_clearance=0.15; // clearance between nuts and bearings - 0.3mm in total
$insert_nut_inset_bottom_adjust=0.5; // bottom side of the roller needs 0.5mm additional inset for the nut to due sagging of top layers when printed with support
$insert_nut_inset=$insert_nut_thickness - $roller_side_clearance + $insert_nut_clearance;
$insert_nut_outset=$insert_nut_thickness - $insert_nut_inset;
$insert_nut_chamfer=0.5;
$square_nut = false;

// paramters for 608Z bearings
$bearing_hole_diameter = 16;
$bearing_inset_depth = 7;
$bearing_inset_diameter = 22.5;

// adjustment mechanism: M4 parameters
$adj_screw_diameter=4.2;
$adj_nut_size=7.5;
$adj_nut_thickness=3.4;
$adj_nut_space=4;

// adjustment mechanism: knob parameters
$knob_height = 12;
$knob_width = 12;
$knob_nut_size=7.1;
$knob_nut_inset=3;

$knob_knurl_wd=3;
$knob_knurl_hg=3;
$knob_knurl_dp=1;
$knob_knurl_e_smooth=1;
$knob_knurl_s_smooth=60;
$knob_knurl_od=$knob_width-($knob_knurl_dp*(100-$knob_knurl_s_smooth)/100);

// attachment plate
$attachment_base_width = $frame_width;
$attachment_base_depth = $frame_depth;
$attachment_base_thickness = 1.5;
$attachment_wall_thickness=1.6;

// test object parameters
$test_roller_diameter=30;
$test_roller_width=$insert_nut_inset*2+5;
$test_knurl_cylinder_od=$test_roller_diameter-($knurl_dp*(100-$knurl_s_smooth)/100);

echo(str("Frame dimensions: ", $frame_width, " x ", $frame_depth, " x ", $frame_height));
echo(str("Cutout dimensions: ", $frame_inner_width, " x ", $frame_inner_depth));
echo(str("Mouting screws: ", ($frame_inner_width+$frame_head_width), " x ", ($frame_inner_depth+$frame_head_width), " (outset from cutout ", $frame_head_width/2, "mm)"));
//echo(str("Roller Distance ", $secondary_roller_x-$primary_roller_x, " + ", $roller_adj_range));
//echo(str("Roller Nut Outset ", $insert_nut_outset));

module nut(size, height)
{
    if( $square_nut )
    {  
        // square nut
        cube([size,size,height],center=true);
    }
    else
    {
        // hex nut
        cylinder($fn=6, d=size/cos(30), h=height, center=true);  
    }
}

module insert_nut_chamfer()
{
    hull()
    {
        translate([0,0,$insert_nut_chamfer])
        nut($insert_nut_size,$eps);
        nut($insert_nut_size+2*$insert_nut_chamfer, $eps);
    }
}

module roller_top_nut_insert(roller_width=$roller_width)
{
    translate([0,0,roller_width-$insert_nut_inset+$insert_nut_thickness/2])
    nut($insert_nut_size,$insert_nut_thickness);
    translate([0,0,roller_width])
    rotate([180,0,0])
    insert_nut_chamfer();
}

module roller_bottom_nut_insert()
{
    translate([0,0,($insert_nut_inset+$insert_nut_inset_bottom_adjust)-$insert_nut_thickness/2])
    nut($insert_nut_size,$insert_nut_thickness);
    insert_nut_chamfer();
}

/* Roller part for the malt mill (required twice) */
module roller()
{
    difference()
    {
        // Knurled cylinder
        knurl(k_cyl_hg= $roller_width, k_cyl_od = $knurl_cylinder_od, knurl_wd=$knurl_wd, knurl_hg=$knurl_hg, knurl_dp=$knurl_dp, e_smooth = $knurl_e_smooth, s_smooth=$knurl_s_smooth);

        // axis trough hole
        translate([0,0,-$eps])
        cylinder(d=$roller_axis_through_hole, h = $roller_width+1, $fn=100);
        // Top nut insert
        roller_top_nut_insert();
        // Bottom nut insert 
        roller_bottom_nut_insert();
    }
}

module base_frame()
{
    difference()
    {
        cube([$frame_width,$frame_depth,$frame_inner_height]);
        translate([$frame_side_width,$frame_head_width,-$eps])
        cube([$frame_inner_width,$frame_inner_depth,$frame_inner_height+2*$eps]);  
    }
}

module axis_through_hole(xpos,zpos=$roller_z)
{
    translate([xpos,-$eps,zpos])
    rotate([-90,0,0])
    cylinder(h=$frame_depth+2*$eps,d=$bearing_hole_diameter);
}

module bearing_cylinder(xpos,zpos=$roller_z)
{
    bearing_cylinder_length=$frame_inner_depth+2*$bearing_inset_depth;
    bearing_cylinder_y=$frame_head_width-$bearing_inset_depth;  
    translate([xpos,bearing_cylinder_y,zpos])
    rotate([-90,0,0])
    cylinder(h=bearing_cylinder_length,d=$bearing_inset_diameter);
}

module adj_through_hole(ypos, zpos=$roller_z, roller_pos=$secondary_roller_x,
frame_width=$frame_width)
{
    translate([frame_width+$eps,ypos,zpos])
    rotate([0,-90,0])
    cylinder(d=$adj_screw_diameter,h=frame_width-roller_pos);
}

module adj_nut_cutout(zpos=$roller_z, roller_pos=$secondary_roller_x+$adj_nut_space)
{
    translate([roller_pos+$roller_adj_range+$bearing_inset_diameter/2,
    -$adj_nut_size/2+$frame_head_width-($bearing_inset_depth)/2,-$adj_nut_size/2+zpos])
    cube([$adj_nut_thickness,$adj_nut_size*2+$frame_inner_depth,$adj_nut_size]);   
}

module mounting_hole(x,y)
{
    translate([x,y,$mounting_hole_depth/2-$eps])
    cylinder(d=$mounting_hole_diameter,h=$mounting_hole_depth, center=true);
}

module attachment_hole(x,y)
{
    translate([x,y,$frame_inner_height+$frame_top_width-15/2+$eps])
    cylinder(d=2.5,h=15, center=true);
}

module chamfered_cylinder(d, h, chamfer_x, chamfer_z)
{
    cylinder(d1=d-2*chamfer_x, d2=d,h=chamfer_z+$eps);
    translate([0,0,chamfer_z])
    cylinder(d=d, h=h-2*chamfer_z+$eps);
    translate([0,0,h-chamfer_z])
    cylinder(d2=d-2*chamfer_x, d1=d,h=chamfer_z);
}

/* Main frame part for the malt mill */
module frame()
{
difference()
{
    // frame without attachment / mounting cutouts
    union()
    {  
        // base frame with cutouts
        difference()
        {
            base_frame();

            // cutouts for primary roller
            axis_through_hole(xpos=$primary_roller_x);
            bearing_cylinder(xpos=$primary_roller_x);

            // cutouts for secondary roller
            hull()
            {
                // through hole secondary roller min_adj
                axis_through_hole(xpos=$secondary_roller_x);
                // throuh hole sceondary roller max_adj
                axis_through_hole(xpos=$secondary_roller_x+$roller_adj_range);
            }
            hull()
            {
                // through hole secondary roller min_adj
                bearing_cylinder(xpos=$secondary_roller_x);
                // throuh hole sceondary roller max_adj
                bearing_cylinder(xpos=$secondary_roller_x+$roller_adj_range);
            }

            // adj through hole front
            adj_through_hole(ypos=$frame_head_width-($bearing_inset_depth)/2);
            // adj through hole back
            adj_through_hole(ypos=$frame_head_width+$frame_inner_depth+($bearing_inset_depth)/2);
            // adj nut cutout
            adj_nut_cutout();
        }

        // frame top and roller overlap
        difference()
        {
            union()
            {
                // top plate
                translate([0,0,$frame_inner_height-$eps])
                cube([$frame_width,$frame_depth,$frame_top_width]);
                
                // roller overlap box
                //overlap_width=$secondary_roller_x-$primary_roller_x;
                overlap_width=$frame_inner_width;
                translate([$frame_width/2-overlap_width/2,$frame_head_width,$roller_z])
                cube([overlap_width,$frame_inner_depth,$frame_inner_height-$roller_z]);
            }

            // top plate opening cutout
            translate([$frame_width/2-($top_opening_width)/2,$frame_depth/2-$top_opening_depth/2, $frame_top_width+$eps])
            cube([$top_opening_width,$top_opening_depth,$frame_inner_height]);
          
            // primary roller clearance cutout
            translate([$primary_roller_x,$frame_head_width-$eps,$roller_z])
            rotate([-90,0,0]) 
            cylinder(h=$frame_depth,d=$roller_diameter+2*$roller_top_clearance);
            
            // secondary roller clearance cutout
            translate([$secondary_roller_x,$frame_head_width-$eps,$roller_z])
            rotate([-90,0,0])
            hull()
            {    
                cylinder(h=$frame_depth,d=$roller_diameter+2*$roller_top_clearance);
                translate([$roller_adj_range,0,0])
                cylinder(h=$frame_depth,d=$roller_diameter+2*$roller_top_clearance);
            }
        }
    }

    mounting_hole($mounting_hole_inset,$mounting_hole_inset);
    mounting_hole($frame_width/2,$mounting_hole_inset);
    mounting_hole($frame_width-$mounting_hole_inset,$mounting_hole_inset);

    mounting_hole($mounting_hole_inset,$frame_depth-$mounting_hole_inset);
    mounting_hole($frame_width/2,$frame_depth-$mounting_hole_inset);
    mounting_hole($frame_width-$mounting_hole_inset,$frame_depth-$mounting_hole_inset);

    attachment_hole($mounting_hole_inset,$mounting_hole_inset);
    attachment_hole($frame_width/2,$mounting_hole_inset);
    attachment_hole($frame_width-$mounting_hole_inset,$mounting_hole_inset);

    attachment_hole($mounting_hole_inset,$frame_depth-$mounting_hole_inset);
    attachment_hole($frame_width/2,$frame_depth-$mounting_hole_inset);
    attachment_hole($frame_width-$mounting_hole_inset,$frame_depth-$mounting_hole_inset);

}
// end frame module
}

module knob()
{
    difference()
    {
        knurl(k_cyl_hg= $knob_height, k_cyl_od = $knob_knurl_od, knurl_dp= $knob_knurl_dp, s_smooth=$knob_knurl_s_smooth, e_smooth=$knob_knurl_e_smooth, knurl_wd=$knob_knurl_wd, knurl_hg=$knob_knurl_hg);
    
        translate([0,0,$knob_height-$knob_nut_inset/2])
        nut($knob_nut_size, $knob_nut_inset+$eps);
    }
}

module spacer()
{
    difference()
    {
        cylinder(d=12,h=10);
        translate([0,0,-$eps]);
        cylinder(d=$roller_axis_through_hole,h=10+2*$eps);
    }
}

module attachment_base_plate()
{
    difference()
    {
        // chamfered base plate
        hull()
        {
            cube([$attachment_base_width, $attachment_base_depth, $eps]);
            translate([$attachment_base_thickness,$attachment_base_thickness,$attachment_base_thickness])
            cube([$attachment_base_width-2*$attachment_base_thickness, $attachment_base_depth+-2*$attachment_base_thickness, $eps]);
        }
        
        // mounting holes
        translate([0,0,-$frame_inner_height+2])
        {
            attachment_hole($frame_head_width/2,$frame_head_width/2);
            attachment_hole($frame_width-$frame_head_width/2,$frame_head_width/2);
            attachment_hole($frame_head_width/2,$frame_depth-$frame_head_width/2);
            attachment_hole($frame_width-$frame_head_width/2,$frame_depth-$frame_head_width/2);
        }
    }
}

module bericap_4841_thread()
{
    for(phi=[0:120:240])
    rotate([0,0,phi])
    translate([0,0,1])
    straight_thread(
        section_profile = bottle_4841_nut_thread_profile(),
        r = bottle_4841_nut_thread_major()/2+$eps,
        pitch = bottle_4841_nut_thread_pitch()*3,
        turns = 0.45,
        higbee_arc = 10,
        fn=$fn
    );
}

/* Attachment plate for bottles with Bericap 48/41 thread */
module attachment_bericap_4841()
{
    neck_height=14; // determined by testing and measuring ...
    thread_z=neck_height-8; 
    
    // base
    difference()
    {
        union()
        { 
            // chamfered base plate
            attachment_base_plate();
            
            // thread neck
            translate([$attachment_base_width/2,$attachment_base_depth/2])
            cylinder(h=neck_height,d1=$attachment_base_depth-2*$attachment_base_thickness,
                                   d2=bottle_4841_nut_thread_major()+2*$attachment_wall_thickness);
        }
        
        // cutout
        translate([$attachment_base_width/2,$attachment_base_depth/2])
        translate([0,0,-$eps])
        cylinder(h=neck_height+1,d=bottle_4841_nut_thread_major());
    }

    // thread
    translate([$attachment_base_width/2,$attachment_base_depth/2,thread_z])
    bericap_4841_thread();
}

/* Test part for testing bearing fitting and adjutment mechanism */
module test_frame()
{
    $test_frame_height=$bearing_inset_diameter+6;
    $test_frame_width=$test_frame_height+$adj_nut_space+$adj_nut_thickness+$roller_adj_range;
    $test_axis_pos=$bearing_inset_diameter/2+3;

    difference()
    {
        // frame piece
        cube([$test_frame_width,$frame_head_width,$test_frame_height]);
        // cutouts
        hull()
        {
            axis_through_hole(xpos=$test_axis_pos,zpos=$test_axis_pos);
            axis_through_hole(xpos=$test_axis_pos+$roller_adj_range,zpos=$test_axis_pos);
        }
        hull()
        {
            bearing_cylinder(xpos=$test_axis_pos,zpos=$test_axis_pos);
            bearing_cylinder(xpos=$test_axis_pos+$roller_adj_range,zpos=$test_axis_pos);
        }
        adj_through_hole(ypos=$frame_head_width-($bearing_inset_depth)/2,
                                    zpos=$test_axis_pos,
                                    roller_pos=$test_axis_pos,
                                    frame_width=$test_frame_width);
        adj_nut_cutout(zpos=$test_axis_pos, roller_pos=$test_axis_pos+$roller_adj_range);
    }
}

/* Test part for testing roller printing and insert nut fitting */
module test_roller()
{
    difference()
    {
        // Knurled cylinder
        knurl(k_cyl_hg= $test_roller_width, k_cyl_od = $test_knurl_cylinder_od, knurl_wd=$knurl_wd, knurl_hg=$knurl_hg, knurl_dp=$knurl_dp, e_smooth = $knurl_e_smooth, s_smooth=$knurl_s_smooth);
        
        // axis trough hole
        translate([0,0,-$eps])
        cylinder(d=$roller_axis_through_hole, h = $test_roller_width+1, $fn=100);
        roller_bottom_nut_insert();
        roller_top_nut_insert(roller_width=$test_roller_width);
    }        
}

/* Rollers translated in position to frame, just for visualisation purposes */
module roller_visual()
{
    translate([$primary_roller_x,($frame_depth-$roller_width)/2,$roller_z])
    rotate([-90,0,0])
    roller();

    translate([$secondary_roller_x,($frame_depth-$roller_width)/2,$roller_z])
    rotate([-90,0,0])
    roller();
}

/* Attachment translated in position to frame, just for visualisation purposes */
module attachment_visual()
{
    translate([$frame_width/2 - $attachment_base_width/2,$frame_depth/2 - $attachment_base_depth/2,$frame_height])
    attachment_bericap_4841();
}

/* Visual assembly for viewing / rendering */
module mill_visual_assembly()
{
    frame();
    roller_visual();
    attachment_visual();
}

/* Uncomment for manul rendering / previewing */

//frame();
//roller();
//knob();
//spacer();
//attachment_bericap_4841();

//test_frame();
//test_roller();
