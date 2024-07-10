$fa=0.5; // default minimum facet angle is now 0.5
$fs=0.5; // default minimum facet size is now 0.5 mm

// Parametric Funnel by Coasterman

// VARIABLES
bottom_diameter = 140;
bottom_height = 120;
top_diameter = 48;
top_height = 50;
width = 2.0;
cone_height = 80;

// CODE
union()
{
difference()
{
cylinder(h=bottom_height, r=bottom_diameter/2 + width);
translate([0,0,-2]) cylinder(h=bottom_height+4, r=bottom_diameter/2);
}
translate([0, 0, bottom_height])
difference()
{
cylinder(h=cone_height, r1=bottom_diameter/2 + width, r2 = top_diameter/2 + width);
translate([0,0,0]) cylinder(h=cone_height, r1=bottom_diameter/2, r2 = top_diameter/2);
}
translate([0, 0, cone_height + bottom_height])
{
difference()
{
cylinder(h=top_height, r=top_diameter/2 + width);
translate([0,0,-2]) cylinder(h=top_height+4, r=top_diameter/2);
}
}
}