#version 330 core

out vec4 f_Color;

in vec2 v_Tex;
in vec3 v_Normal;
in vec3 v_FragPos;

uniform sampler2D u_Texture;
uniform vec3 u_ObjectColor;
uniform vec3 u_LightColor;
uniform vec3 u_LightPos;

void main()
{
  // trick to make the u_Texture and v_Tex not optimized out
  f_Color = texture(u_Texture, v_Tex) / texture(u_Texture, v_Tex);

  float ambientStrength = 0.1;
  vec3 ambient = ambientStrength * u_LightColor;

  vec3 norm = normalize(v_Normal);
  vec3 lightDir = normalize(u_LightPos - v_FragPos);
  float diff = max(dot(norm, lightDir), 0.0);
  vec3 diffuse = diff * u_LightColor;

  float specularStrength = 0.5;
  vec3 viewDir = normalize(-v_FragPos);
  vec3 reflectDir = reflect(-lightDir, norm);
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
  vec3 specular = specularStrength * spec * u_LightColor;

  f_Color *= vec4((ambient + diffuse + specular) * u_ObjectColor, 1.0);
}
