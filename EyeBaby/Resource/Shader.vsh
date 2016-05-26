uniform mat4 in_transform;
uniform vec2 in_tex_scale_y;
uniform vec2 in_tex_scale_uv;

attribute vec4 in_position;
attribute vec2 in_tex_coord;

varying lowp vec2 out_tex_coord_y;
varying lowp vec2 out_tex_coord_uv;

void main()
{
    out_tex_coord_y = in_tex_coord * in_tex_scale_y;
    out_tex_coord_uv = in_tex_coord * in_tex_scale_uv;
    
    gl_Position = in_transform * in_position;
}
