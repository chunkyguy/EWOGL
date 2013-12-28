/** Diffuse shading: Vertex shader */

attribute vec4 a_Position; /*vertex position in object space*/
attribute vec3 a_Normal; /*vertex normal in object space*/

uniform vec4 u_Light; /*light position in eye space*/
uniform mat3 u_N; /*normal matrix to transform normals from object space to eye space*/
uniform mat4 u_Mv; /*modelview matrix to transform position from object space to eye space*/
uniform mat4 u_P; /*projection matrix to transform position from eye space to clip space*/
uniform mat4 u_Mvp; /*mvp matrix to transform position from object space to clip space*/

varying lowp vec4 v_Color; /*per vertex color to be interpolated in frag shader*/

void main()
{
 /* 1. Set color for the model*/
 vec4 diffuseColor = vec4(0.7, 0.6, 0.3, 1.0);

 /* 2. Convert normals from object space to eye space*/
 vec3 eyeNormal = normalize(u_N * a_Normal);

 /* 3. Convert position to eye space*/
 vec4 eyePosition = normalize(u_Mv * a_Position);

 /* 4. Calculate light vector
  * lightVector = u_Light - eyePosition (vertex position in eye space)
  * If u_Light is very distant (eg Sun), 
  * a_Position == origin
  * lightVector = u_Light
  */
 vec3 lightVector = normalize(vec3(u_Light - eyePosition));
 //vec3 lightVector = vec3(u_Light);
 
 /* 5. Calculate diffuse factor as DOT product of normal and light vector
  * In eye space
  */
 float diffuseFactor = max(dot(lightVector, eyeNormal), 0.0);

 /* 6. Calculate effective diffuse color at this vertex
  * Pass it to the frag shader to be interpolated
  */
 v_Color = diffuseColor * diffuseFactor;
 
 /* 7. Calculate position in clip space */
 gl_Position = u_Mvp * a_Position;
}
