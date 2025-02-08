#version 330 core

in vec3 a_Pos;
in vec2 a_Tex;

out vec2 v_Tex;

uniform mat4 u_Model;
uniform mat4 u_View;
uniform mat4 u_Projection;

void main() {
  gl_Position = u_Projection * u_View * u_Model * vec4(a_Pos, 1.0);
  v_Tex = a_Tex;
}
