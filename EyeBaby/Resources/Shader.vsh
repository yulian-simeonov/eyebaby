//
//  Shader.vsh
//

uniform mat4 in_transform;
uniform vec2 in_tex_scale;

attribute vec4 in_position;
attribute vec2 in_tex_coord;

varying lowp vec2 out_tex_coord;

void main()
{
    out_tex_coord = in_tex_coord * in_tex_scale;
    gl_Position = in_transform * in_position;
}
