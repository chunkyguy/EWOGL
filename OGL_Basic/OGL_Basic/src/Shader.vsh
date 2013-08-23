attribute highp vec4 a_Positon;

uniform mediump mat4 u_Mvp;

void main(void) {
	gl_Position = u_Mvp * a_Positon;
}