#version 330 core

in vec3 a_Pos;

uniform mat4 u_Model;
uniform mat4 u_View;
uniform mat4 u_Projection;

void main() {
  gl_Position = u_Projection * u_View * u_Model * vec4(a_Pos, 1.0);
}
