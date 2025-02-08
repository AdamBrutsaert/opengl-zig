#version 330 core

struct Material {
  vec3 ambient;
  vec3 diffuse;
  vec3 specular;
  float shininess;
};

struct Light {
  vec3 position;
  vec3 ambient;
  vec3 diffuse;
  vec3 specular;
};

out vec4 f_Color;

in vec2 v_Tex;
in vec3 v_Normal;
in vec3 v_FragPos;

uniform sampler2D u_Texture;
uniform Material u_Material;
uniform Light u_Light;

void main()
{
  // trick to make the u_Texture and v_Tex not optimized out
  f_Color = texture(u_Texture, v_Tex) / texture(u_Texture, v_Tex);

  // Ambient
  vec3 ambient = u_Light.ambient * u_Material.ambient;

  // Diffuse
  vec3 norm = normalize(v_Normal);
  vec3 lightDir = normalize(u_Light.position - v_FragPos);
  float diff = max(dot(norm, lightDir), 0.0);
  vec3 diffuse = u_Light.diffuse * diff * u_Material.diffuse;

  // Specular
  vec3 viewDir = normalize(-v_FragPos);
  vec3 reflectDir = reflect(-lightDir, norm);
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), u_Material.shininess);
  vec3 specular = u_Light.specular * spec * u_Material.specular;

  // Combine results
  vec3 result = ambient + diffuse + specular;
  f_Color *= vec4(result, 1.0);
}
