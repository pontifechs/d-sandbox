import std.stdio;

import buffer, shader;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;



void main(string[] args)
{
	DerelictGL3.load();
	DerelictGLFW3.load();
 
	if (!glfwInit())
		throw new Exception("Failed to initialize GLFW3");
	scope(exit) glfwTerminate();
 
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
	auto window = glfwCreateWindow(800, 600, "GLASS", null, null);
	assert(window !is null);
	glfwMakeContextCurrent(window);
 
	auto vers = DerelictGL3.reload();


	auto shader = new Shader("simple.glsl");
	shader.bind();
 
	float[] rawVerts = [-1, -1, 0,
						1, -1, 0,
						0, 1, 0];
	auto vertices = new Buffer(rawVerts);
	auto vertArray = new VertexArray();
	vertArray.bind(0, GL_FLOAT, 3, 3 * float.sizeof);


	glClearColor(0.2, 0.2, 0.2, 1.0);
 
	while (!glfwWindowShouldClose(window))  {
 
		glfwPollEvents();
		if ( glfwGetKey( window, GLFW_KEY_ESCAPE ) == GLFW_PRESS )
			break;
 
		glClear(GL_COLOR_BUFFER_BIT);
		glDrawArrays(GL_TRIANGLES, 0, cast(int)rawVerts.length);
 
		glfwSwapBuffers(window);
	}
}

