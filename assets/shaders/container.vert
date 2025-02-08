#version 330 core

in vec3 a_Pos;
in vec2 a_Tex;
in vec3 a_Normal;

out vec2 v_Tex;
out vec3 v_Normal;
out vec3 v_FragPos;

uniform mat4 u_Model;
uniform mat4 u_View;
uniform mat4 u_Projection;

void main() {
  mat4 view_model = u_View * u_Model;
  gl_Position = u_Projection * view_model * vec4(a_Pos, 1.0);
  v_Tex = a_Tex;
  v_Normal = mat3(transpose(inverse(view_model))) * a_Normal;
  v_FragPos = vec3(view_model * vec4(a_Pos, 1.0));
}
