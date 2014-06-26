
module deagle.graphics.GL;

import std.typecons;
import std.stdio;
import std.traits;

import derelict.opengl3.gl3;

import deagle.util.CallHistory;

// Singleton for access to OpenGL through an intermediary
// This allows us to be able to mock this out,
// as well as insert instrumentation/logging code to
// collect statistics and other such niceities.

// If we're running unittests, use the mock.
// (may at some point replace with a different version e.g. mockGLCalls or something)
version(unittest)
{
	alias GL = MockableGL!(Yes.Mock);
}
else
{
	alias GL = MockableGL!(No.Mock);
}


class MockableGL(Flag!"Mock" mocked)
{
public:

	// Return the static instance
	// the mocked flag is a hint, indicating whether or not we're asking 
	// for a mock instead. The instance will always behave the same way, 
	// so only the first time the instance is requested will it actually matter.
	static MockableGL opCall()
	{
		if (instance is null)
		{
			instance = new GL();
		}
		return instance;
	}

	// Dispatch all existing calls to their C binding.
	auto opDispatch(string s, T...)(T args)
		if (is(typeof(&mixin("gl" ~ s)))) // Make sure the function exists
	{
		string fnName = "gl" ~ s;
		
		static if (!mocked)
		{
			// Call the C binding
			mixin("return gl" ~ s ~ "(args);");    
		}
		else
		{
			// Log the call
			history ~= Call.make!(mixin("gl" ~s))(args);

			// Return the .init of the fn's return type (as long as it's not void)
			static if (!is(ReturnType!(mixin("gl" ~s)) == void))
			{
				return ReturnType!(mixin("gl" ~ s)).init;
			}
		}
	}



	static if (mocked)
	{
		CallHistory history;
	}


private:
	// Disallow construction
	this() { }

	static MockableGL instance;

}

// unittest // opDispatch debugging (bopDispatch) Due to bugzilla 8387
// {
// 	import deagle.math.Matrix;

// 	auto m4f = new Matrix!(4,4,float)();

// 	auto GL = GL();
// 	scope(exit) GL.instance = null;
// 	GL.bopDispatch!"UniformMatrix4fv"(0, 1, GL_FALSE, m4f.ptr);
	
// }

unittest // Calls are forwarded properly, failing to compile if they don't exist.
{
	import std.traits; 

	auto GL = GL();

	assert(!__traits(compiles, GL.THISDOESNTEXIST(1,2,3)), 
				 "Compiled with nonsense GL call");	
	assert(__traits(compiles, GL.ClearColor(0.2, 0.2, 0.2, 1.0)), 
				 "Didn't compile real GL call");
	assert(!__traits(compiles, GL.ClearColor()),
		     "Compiled real GL call with bad arguments");
}


unittest // Logging
{
	auto GL = GL();
	scope(exit) GL.instance = null;
	
	auto history = CallHistory();

	// Make some calls
	GL.ClearColor(0.2, 0.2, 0.2, 1.0);
	history ~= Call.make!(glClearColor)(0.2, 0.2, 0.2, 1.0);

	GL.ClearColor(0.3, 0.3, 0.3, 1.0);
	history ~= Call.make!(glClearColor)(0.3, 0.3, 0.3, 1.0);

	GL.Uniform1i(0, 1);
	history ~= Call.make!(glUniform1i)(0, 1);

	GL.Uniform1f(0, 1.0);
	history ~= Call.make!(glUniform1f)(0, 1.0);
	
	assert(history == GL.history);
}
