/**
 text mesh shader
 */

varying lowp vec2 v_TexCoords;
varying lowp vec4 v_Color;
uniform sampler2D u_Texture;

void main(void) {
 gl_FragColor = vec4(1.0, 1.0, 1.0, texture2D(u_Texture, v_TexCoords).a) * v_Color;
}