/** ADS shading: Vertex shader */

/*vertex attributes*/
attribute vec4 a_Position; /*vertex position in object space*/
attribute vec3 a_Normal; /*vertex normal in object space*/

/*light attributes*/
uniform vec4 u_LightColor; /*Adds to the gloss color and ambience*/
uniform vec4 u_LightPosition; /*light position in eye space*/

/*material attributes*/
uniform vec4 u_MaterialColor; /*color of the material*/
uniform float u_MaterialGloss; /*how glossy the object is*/

/*transformation matrices*/
uniform mat3 u_N; /*normal matrix to transform normals from object space to eye space*/
uniform mat4 u_Mv; /*modelview matrix to transform position from object space to eye space*/
uniform mat4 u_Mvp; /*mvp matrix to transform position from object space to clip space*/

varying lowp vec4 v_Color; /*per vertex color to be interpolated in frag shader*/

void main()
{
 /* 1. Convert normals from object space to eye space*/
 vec3 eyeNormal = normalize(u_N * a_Normal);
 
 /* 2. Convert position to eye space*/
 vec4 eyePosition = normalize(u_Mv * a_Position);
 
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
 float diffuseFactor = max(dot(lightVector, eyeNormal), 0.0);

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
 v_Color = u_MaterialColor * diffuseFactor + u_LightColor * specularFactor;
 
 /* 7. Calculate position in clip space */
 gl_Position = u_Mvp * a_Position;
}
