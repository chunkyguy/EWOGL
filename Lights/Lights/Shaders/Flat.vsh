#version 300 es
/** Flat shading: Vertex shader */

/*vertex attributes*/
layout (location = 0) in vec4 a_Position; /*vertex position in object space*/
layout (location = 5) in vec3 a_Normal; /*vertex normal in object space*/

flat out vec4 v_Color; /*per vertex color to be passed to frag shader without interpolation*/

/*light attributes*/
uniform vec4 u_LightPosition; /*light position in eye space*/

/*material attributes*/
uniform vec4 u_MaterialColor; /*color of the material*/

/*transformation matrices*/
uniform mat3 u_N; /*normal matrix to transform normals from object space to eye space*/
uniform mat4 u_Mv; /*modelview matrix to transform position from object space to eye space*/
uniform mat4 u_Mvp; /*mvp matrix to transform position from object space to clip space*/


void main()
{
 /* 1. Convert normals from object space to eye space*/
 vec3 eyeNormal = normalize(u_N * a_Normal);

 /* 2. Convert position to eye space*/
 vec4 eyePosition = normalize(u_Mv * a_Position);

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
  * Pass it to the frag shader
  */
 v_Color = u_MaterialColor * diffuseFactor;
 
 /* 7. Calculate position in clip space */
 gl_Position = u_Mvp * a_Position;
}
