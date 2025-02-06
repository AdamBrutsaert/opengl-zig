#version 330 core

in vec3 a_Pos;
in vec3 a_Color;
in vec2 a_Tex;

out vec3 v_Color;
out vec2 v_Tex;

uniform mat4 u_Transform;

void main() {
  gl_Position = u_Transform * vec4(a_Pos, 1.0);
  v_Color = a_Color;
  v_Tex = a_Tex;
}
