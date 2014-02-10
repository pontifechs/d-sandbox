import std.stdio;
import std.conv;
import std.typecons;

import buffer, shader;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

struct GLFW(bool mock = false)
{

	auto opDispatch(string s, T...)(T args)
	{
		string fnName = "glfw" ~ s;
		static assert(is(typeof(&mixin("fnName"))));

		// Call the C binding
		//writeln("Calling " ~ s);
		mixin("return glfw" ~ s ~ "(args);");
	}
}

class GL
{
	auto opDispatch(string s, T...)(T args)
		if (is(typeof(&mixin("gl" ~ s))))
	{
		string fnName = "gl" ~ s;
		//static assert(is(typeof(&mixin("fnName"))),"tits");

		auto copy = args;

		// Call the C binding
		writeln("Calling " ~ s);
		mixin("return gl" ~ s ~ "(args);");
	}
}

void main(string[] args)
{
	DerelictGL3.load();
	DerelictGLFW3.load();
 
	if (!glfwInit())
		throw new Exception("Failed to initialize GLFW3");
	scope(exit) glfwTerminate();

	auto GLFW = new GLFW!();
	auto GL = new GL();
 
	GLFW.WindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	GLFW.WindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	GLFW.WindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	GLFW.WindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
	auto window = glfwCreateWindow(800, 600, "GLASS", null, null);
	assert(window !is null);
	GLFW.MakeContextCurrent(window);

	auto vers = DerelictGL3.reload();


	auto shader = new Shader("simple.glsl");
	shader.bind();
 
	float[] rawVerts = [-1, -1, 0,
						1, -1, 0,
						0, 1, 0];
	auto vertices = new Buffer(rawVerts);
	auto vertArray = new VertexArray();
	vertArray.bind(0, GL_FLOAT, 3, 3 * float.sizeof);


	GL.ClearColor(0.2, 0.2, 0.2, 1.0);

	 
	int bob = 0;

	while (!GLFW.WindowShouldClose(window))  {
 
		GLFW.PollEvents();
					
		if (bob == 0)
		{
			if ( GLFW.GetKey( window, GLFW_KEY_ESCAPE ) == GLFW_PRESS )
				break;
 
			GL.Clear(GL_COLOR_BUFFER_BIT);
			GL.DrawArrays(GL_TRIANGLES, 0, cast(int)rawVerts.length);
 
			GLFW.SwapBuffers(window);
			bob++;
		}
	}
}

