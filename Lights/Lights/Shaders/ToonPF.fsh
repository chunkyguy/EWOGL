/** Toon shading: Frag shader */

precision lowp float;

/*light attributes*/
uniform vec4 u_LightColor; /*Adds to the gloss color and ambience*/
uniform vec4 u_LightPosition; /*light position in eye space*/

/*material attributes*/
uniform vec4 u_MaterialColor; /*color of the material*/
uniform float u_MaterialGloss; /*how glossy the object is*/

varying lowp vec4 v_Position; /*final color; interpolated between per vertex color calculate in vert shader*/
varying lowp vec3 v_Normal;

/*transformation matrices*/
uniform mat3 u_N; /*normal matrix to transform normals from object space to eye space*/
uniform mat4 u_Mv; /*modelview matrix to transform position from object space to eye space*/

const float levels = 4.0; /*clamp to fixed number of color shades*/

void main()
{
 /* 1. Convert normals from object space to eye space*/
 vec3 eyeNormal = normalize(u_N * v_Normal);
 
 /* 2. Convert position to eye space*/
 vec4 eyePosition = normalize(u_Mv * v_Position);
 
 /* 3. Calc eye vector as inverse of eyePosition*/
 vec3 eyeVector = normalize(-eyePosition.xyz);
 
 /* 4. Calculate light vector
  * lightVector = u_LightPosition - eyePosition (vertex position in eye space)
  * If u_LightPosition is very distant (eg Sun),
  * a_Position == origin
  * lightVector = u_LightPosition
  */
 vec3 lightVector = normalize(vec3(u_LightPosition - eyePosition));
 //vec3 lightVector = vec3(u_LightPosition);
 
 /* 5. Calculate diffuse factor as DOT product of normal and light vector
  * In eye space
  */
 float diffuseFactor = floor(max(dot(lightVector, eyeNormal), 0.0) * levels) / levels;
 
 /* 6. Calc reflection vector as reflection of light vector about eyeNormal*/
 vec3 reflectionVector = reflect(-lightVector, eyeNormal);
 
 /* 7. Calc specular highlight */
 float specularFactor = 0.0;
 if (diffuseFactor > 0.0) {
  specularFactor = pow(max(dot(eyeVector, reflectionVector), 0.0), u_MaterialGloss);
 }
 /* 8. Calculate effective color at this vertex
  * Pass it to the frag shader to be interpolated
  */
 gl_FragColor = u_MaterialColor * diffuseFactor + u_LightColor * specularFactor;
}
