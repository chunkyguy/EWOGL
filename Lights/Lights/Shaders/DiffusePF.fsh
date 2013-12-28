/** Diffuse shading per frag: Frag shader */

precision highp float;

varying vec3 v_Normal; /*normal interpolated between per vertex color calculate in vert shader*/
varying vec4 v_Position;

/*light attributes*/
uniform vec4 u_LightPosition; /*light position in eye space*/

/*material attributes*/
uniform vec4 u_MaterialColor; /*color of the material*/

/*transformation matrices*/
uniform mat3 u_N; /*normal matrix to transform normals from object space to eye space*/
uniform mat4 u_Mv; /*modelview matrix to transform position from object space to eye space*/

void main()
{
 /* 1. Convert normals from object space to eye space*/
 vec3 eyeNormal = normalize(u_N * v_Normal);
 
 /* 2. Convert position to eye space*/
 vec4 eyePosition = normalize(u_Mv * v_Position);
 
 /* 3. Calculate light vector
  * lightVector = u_LightPosition - eyePosition (vertex position in eye space)
  * If u_LightPosition is very distant (eg Sun),
  * a_Position == origin
  * lightVector = u_LightPosition
  */
 vec3 lightVector = normalize(vec3(u_LightPosition - eyePosition));
 //vec3 lightVector = vec3(u_LightPosition);
 
 /* 4. Calculate diffuse factor as DOT product of normal and light vector
  * In eye space
  */
 float diffuseFactor = max(dot(lightVector, eyeNormal), 0.0);
 
 /* 5. Calculate effective color at this vertex
  * Pass it to the frag shader to be interpolated
  */
 gl_FragColor = u_MaterialColor * diffuseFactor;
}
