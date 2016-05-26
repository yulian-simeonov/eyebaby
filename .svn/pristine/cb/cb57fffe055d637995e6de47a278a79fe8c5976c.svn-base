uniform sampler2D texY;
uniform sampler2D texU;
uniform sampler2D texV;

varying lowp vec2 out_tex_coord_y;
varying lowp vec2 out_tex_coord_uv;

void main()
{    
    lowp float y = texture2D(texY, out_tex_coord_y).r;
    lowp float u = texture2D(texU, out_tex_coord_uv).r - 0.5;
    lowp float v = texture2D(texV, out_tex_coord_uv).r - 0.5;
    
    lowp float r = y + 1.402 * v;
    lowp float g = y - 0.34414 * u - 0.71414 * v;
    lowp float b = y + 1.772 * u;
    
    gl_FragColor = vec4(r, g, b, 1.0);
}
