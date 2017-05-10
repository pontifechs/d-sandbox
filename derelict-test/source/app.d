import std.stdio;
import std.conv;
import std.typecons;
import std.exception;

import buffer, shader;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

class GL
{
	auto opDispatch(string s, T...)(T args)
		if (is(typeof(&mixin("gl" ~ s))))
	{
		string fnName = "gl" ~ s;
		mixin("return gl" ~ s ~ "(args);");
	}
}

static extern (C) void error_callback (int, const (char)* error) nothrow {
	import std.c.stdio: fprintf, stderr;
	fprintf (stderr, "error glfw: %s\n", error);
}

void main(string[] args)
{
	DerelictGL3.load();
	DerelictGLFW3.load();

	glfwSetErrorCallback(&error_callback);
	if (!glfwInit())
	{
		throw new Exception("Failed to initialize GLFW3");
	}
	scope(exit) glfwTerminate();

	auto GL = new GL();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

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

	GL.ClearColor(0.15, 0.15, 0.15, 1.0);

	while (!glfwWindowShouldClose(window))  
	{
		glfwPollEvents();

		if ( glfwGetKey( window, GLFW_KEY_ESCAPE ) == GLFW_PRESS )
		{
			break;
		}

		GL.Clear(GL_COLOR_BUFFER_BIT);
		GL.DrawArrays(GL_TRIANGLES, 0, cast(int)rawVerts.length);

		glfwSwapBuffers(window);
	}
}







