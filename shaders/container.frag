#version 330 core

out vec4 f_Color;

in vec3 v_Color;
in vec2 v_Tex;

uniform sampler2D u_Texture1;
uniform sampler2D u_Texture2;

uniform float u_Mix1;
uniform float u_Mix2;

void main()
{
  f_Color = mix(mix(texture(u_Texture1, v_Tex), texture(u_Texture2, v_Tex), u_Mix1), vec4(v_Color, 1.0), u_Mix2);
}
