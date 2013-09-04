/** Diffuse lighting. */

attribute highp vec4 a_Position;	// Vertex position
attribute highp vec3 a_Normal;	// Vertex surface normal.

varying lowp vec4 v_Color;		// Color to be passed to the frag shader, 

uniform mediump mat4 u_Mvp;		// Model-view-projection matrix; used to convert vertex positions
								// from object-space to eye-space.

uniform mediump mat3 u_N;		// Normal matrix, which is most often inverse-transpose of model-view matrix
								// with translation part discarded. Used to convert normals from object-space
								// to eye-space.

void main(void) {

	// 1. Convert normal from object-space to eye-space
	vec3 eye_normal = u_N * a_Normal;

	// 2. Assume a light position at some position
	vec3 light_position = vec3(0.0, 0.0, 1.0);

	// 3. Calculate the light vector as:
	//			vec3 light_vector = light_position - aPosition.
	//	But, if the light is very far (like the sun), the aPostion vector can be assumed to be at origin. Hence,
	//			vec3 light_vector = light_position.
	//vec3 light_vector = light_position - a_Position.xyz;	// Case: Directional light. Like usual light sources.
	vec3 light_vector = light_position;						// Case: Positional light. Like sun.
	
	// 4. Calculate the diffuse factor. It is basically a dot product between normal and the light vector
	//	The dot product returns a scalar value, we don't want it to be negative. As, anything that is less than 0
	//	contriubtes nothing to light, and there is no such thing as negative dark.
	float diffuse_factor = max(0.0, dot(normalize(eye_normal), normalize(light_vector)));
	
	// 5. Assume some diffuse color, which is the material's color.
	vec4 diffuse_color = vec4(1.0, 1.0, 0.66, 1.0);
	
	// 6. Calculate the final diffuse color for this vertex, and pass it to the frag shader where it is going to be linearly interpolated.
	v_Color = diffuse_color * diffuse_factor;

	// 7. Calculate the position in the eye-space.
	gl_Position = u_Mvp * a_Position;
}