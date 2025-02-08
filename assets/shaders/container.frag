#version 330 core

struct Material {
  sampler2D diffuse;
  sampler2D specular;
  float shininess;
};

struct DirectionalLight {
  vec3 direction;
  vec3 ambient;
  vec3 diffuse;
  vec3 specular;
};

struct PointLight {
  vec3 position;
  float constant;
  float linear;
  float quadratic;
  vec3 ambient;
  vec3 diffuse;
  vec3 specular;
};

#define POINT_LIGHTS 4

out vec4 f_Color;

in vec2 v_Tex;
in vec3 v_Normal;
in vec3 v_FragPos;

uniform Material u_Material;
uniform DirectionalLight u_DirectionalLight;
uniform PointLight u_PointLights[POINT_LIGHTS];

vec3 calc_directional_light(DirectionalLight light, vec3 normal, vec3 viewDir)
{
  vec3 lightDir = normalize(-light.direction);
  vec3 reflectDir = reflect(-lightDir, normal);

  float diff = max(dot(normal, lightDir), 0.0);
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), u_Material.shininess);

  vec3 ambient = light.ambient * vec3(texture(u_Material.diffuse, v_Tex));
  vec3 diffuse = light.diffuse * diff * vec3(texture(u_Material.diffuse, v_Tex));
  vec3 specular = light.specular * spec * vec3(texture(u_Material.specular, v_Tex));

  return ambient + diffuse + specular;
}

vec3 calc_point_light(PointLight light, vec3 normal, vec3 viewDir)
{
  vec3 lightDir = normalize(light.position - v_FragPos);
  vec3 reflectDir = reflect(-lightDir, normal);
  float distance = length(light.position - v_FragPos);
  float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));

  float diff = max(dot(normal, lightDir), 0.0);
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), u_Material.shininess);

  vec3 ambient = attenuation * light.ambient * vec3(texture(u_Material.diffuse, v_Tex));
  vec3 diffuse = attenuation * light.diffuse * diff * vec3(texture(u_Material.diffuse, v_Tex));
  vec3 specular = attenuation * light.specular * spec * vec3(texture(u_Material.specular, v_Tex));

  return ambient + diffuse + specular;
}

void main()
{
  vec3 norm = normalize(v_Normal);
  vec3 viewDir = normalize(-v_FragPos);

  vec3 result = calc_directional_light(u_DirectionalLight, norm, viewDir);

  for (int i = 0; i < POINT_LIGHTS; i++)
    result += calc_point_light(u_PointLights[i], norm, viewDir);

  f_Color = vec4(result, 1.0);
}
