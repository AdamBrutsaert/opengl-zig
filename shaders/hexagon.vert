#version 460 core

uniform vec2 u_FramebufferSize;
uniform float u_Angle;

in vec4 a_Position;
in vec4 a_Color;

out vec4 v_Color;

void main() {
  float scaleX = min(u_FramebufferSize.y / u_FramebufferSize.x, 1);
  float scaleY = min(u_FramebufferSize.x / u_FramebufferSize.y, 1);

  float s = sin(u_Angle);
  float c = cos(u_Angle);

  gl_Position =
      vec4((a_Position.x * c + a_Position.y * -s) * scaleX,
           (a_Position.x * s + a_Position.y * c) * scaleY, a_Position.zw) *
      vec4(0.875, 0.875, 1, 1);

  v_Color = a_Color;
}
