//
//  Shader.c
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "std_incl.h"
#include "Shader.h"

#include "Utilities.h"
#include "Constants.h"

Program CompileShader(const char *vsh_filename, const char *fsh_filename, BindAttribs bind_attribs) {
	char vsh_src[kBuffer(12)] = {0};
	char fsh_src[kBuffer(12)] = {0};
	char path_buffer[kBuffer(10)] = {0};
	
	BundlePath(vsh_filename, path_buffer);
	ReadFile(path_buffer, vsh_src);

	BundlePath(fsh_filename, path_buffer);
	ReadFile(path_buffer, fsh_src);
	
	return CompileShaderSource(vsh_src, fsh_src, bind_attribs);
}

Program CompileShaderSource(const char *vsh_src, const char *fsh_src, BindAttribs bind_attribs) {

	Program program;
	GLint bShaderCompiled;

	// Loads the vertex shader
	program.vert_shader = glCreateShader(GL_VERTEX_SHADER);
	assert(program.vert_shader);
	
	glShaderSource(program.vert_shader, 1, (const char**)&vsh_src, NULL);
	glCompileShader(program.vert_shader);

	glGetShaderiv(program.vert_shader, GL_COMPILE_STATUS, &bShaderCompiled);
	if (!bShaderCompiled)	{
		char info_log[kBuffer(10)] = {0};
		int info_log_len, chars_written;
		glGetShaderiv(program.vert_shader, GL_INFO_LOG_LENGTH, &info_log_len);
		glGetShaderInfoLog(program.vert_shader, info_log_len, &chars_written, info_log);
		printf("Failed to compile vertex shader: %s\n", info_log);
		assert(0);
	}

	// Create the fragment shader object
	program.frag_shader = glCreateShader(GL_FRAGMENT_SHADER);
	assert(program.frag_shader);
	
	glShaderSource(program.frag_shader, 1, (const char**)&fsh_src, NULL);
	glCompileShader(program.frag_shader);

	glGetShaderiv(program.frag_shader, GL_COMPILE_STATUS, &bShaderCompiled);
	if (!bShaderCompiled) {
		char info_log[kBuffer(10)] = {0};
		int info_log_len, chars_written;

		glGetShaderiv(program.frag_shader, GL_INFO_LOG_LENGTH, &info_log_len);
		glGetShaderInfoLog(program.frag_shader, info_log_len, &chars_written, info_log);
		printf("Failed to compile fragment shader: %s\n", info_log);
		assert(0);
	}
	
	// Create the shader program
	program.program = glCreateProgram();
	assert(program.program);
	
	// Attach the fragment and vertex shaders to it
	glAttachShader(program.program, program.vert_shader);
	glAttachShader(program.program, program.frag_shader);
	
	//Bind attributes
	bind_attribs(&program);
	
	
	// Link the program
	glLinkProgram(program.program);
	
	// Check if linking succeeded in the same way we checked for compilation success
	GLint bLinked;
	glGetProgramiv(program.program, GL_LINK_STATUS, &bLinked);
	if (!bLinked) {
		char info_log[kBuffer(10)] = {0};
		int info_log_len, chars_written;

		glGetProgramiv(program.program, GL_INFO_LOG_LENGTH, &info_log_len);
		glGetProgramInfoLog(program.program, info_log_len, &chars_written, info_log);
		printf("Failed to link program: %s\n", info_log);
		assert(0);
	}
	
	// Actually use the created program
	glUseProgram(program.program);

	return program;
}

void ReleaseShader(const Program program) {
	glDetachShader(program.program, program.vert_shader);
	glDeleteShader(program.vert_shader);

	glDetachShader(program.program, program.frag_shader);
	glDeleteShader(program.frag_shader);
	
	glDeleteProgram(program.program);
}

