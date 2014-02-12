
module deagle.graphics.GL;

import std.typecons;
import std.stdio;
import std.traits;

import derelict.opengl3.gl3;

// Singleton for access to OpenGL through an intermediary
// This allows us to be able to mock this out,
// as well as insert instrumentation/logging code to
// collect statistics and other such niceities.
class GL
{
public:

	// Return the static instance
	// the mocked flag is a hint, indicating whether or not we're asking 
	// for a mock instead. The instance will always behave the same way, 
	// so only the first time the instance is requested will it actually matter.
	static GL opCall(Flag!"Mock" mocked = No.Mock)
	{
		if (instance is null)
		{
			instance = new GL(mocked);
		}
		return instance;
	}

	// Dispatch all existing calls to their C binding.
	auto opDispatch(string s, T...)(T args)
		if (is(typeof(&mixin("gl" ~ s)))) // Make sure the function exists
	{
		string fnName = "gl" ~ s;
		
		if (m_isMocked == No.Mock)
		{
			// Call the C binding
			mixin("return gl" ~ s ~ "(args);");    
		}
		else
		{
			// Return the .init of the fn's return type (as long as it's not void)
			static if (!is(ReturnType!(mixin("gl" ~s)) == void))
			{
				return ReturnType!(mixin("gl" ~ s)).init;
			}
		}
	}

private:

 	this(Flag!"Mock" mocked) 
	{
		m_isMocked = mocked;
	}
	
	static GL instance;

	Flag!"Mock" m_isMocked;
}


unittest // Only the first request takes
{
	auto gl = GL();
	assert(gl.m_isMocked == No.Mock);

	auto gl2 = GL(Yes.Mock);
	assert(gl.m_isMocked == No.Mock);

	// Clear out the instance to prevent contamination
	GL.instance = null;
}


unittest // Only the first request takes (reverse order)
{
	auto gl = GL(Yes.Mock);
	assert(gl.m_isMocked == Yes.Mock);

	auto gl2 = GL();
	assert(gl.m_isMocked == Yes.Mock);

	// Clear out the instance to prevent contamination
	GL.instance = null;
}


unittest // Calls are forwarded properly, failing to compile if they don't exist.
{
	import std.traits; 

	auto GL = GL(Yes.Mock);

	assert(!__traits(compiles, GL.THISDOESNTEXIST(1,2,3)), 
				 "Compiled with nonsense GL call");	
	assert(__traits(compiles, GL.ClearColor(0.2, 0.2, 0.2, 1.0)), 
				 "Didn't compile real GL call");
	assert(!__traits(compiles, GL.ClearColor()),
		     "Compiled real GL call with bad arguments");


	// Clear out the instance to prevent contamination
	GL.instance = null;
}

