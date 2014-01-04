//
//  Shader.fsh
//  Cubemap
//
//  Created by Sid on 02/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

uniform samplerCube u_CubeTex;
struct Material {
 lowp float ref_index; /*ratio of refractive index (n2/n1)*/
 lowp float relection; /*ratio of light reflected*/
};
uniform Material u_Material;

varying lowp vec3 v_RefractDir;
varying lowp vec3 v_ReflectDir;

void main()
{
 lowp vec4 reflect_color = textureCube(u_CubeTex, v_ReflectDir);
 lowp vec4 refract_color = textureCube(u_CubeTex, v_RefractDir);
 gl_FragColor = mix(refract_color, reflect_color, u_Material.relection);
}
