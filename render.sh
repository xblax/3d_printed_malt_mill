#!/bin/bash

render_stl()
{
  echo "Render '$1.stl' ..."
  openscad -D "$1()" -o "$2/$1.stl" src/mill.scad
  echo ""
}

render_stl "frame" "stl"
render_stl "roller" "stl"
render_stl "knob" "stl"
render_stl "spacer" "stl"
render_stl "attachment_bericap_4841" "stl"
render_stl "test_frame" "stl/testparts"
render_stl "test_roller" "stl/testparts"

# openscad --render --viewall --imgsize=3000,2000 --colorscheme=BeforeDawn -D "mill_visual_assembly()" src/mill.scad -o images/mill_render.png

echo ""
echo "Freecad STLs must be updated manually!"
