module deagle.graphics.Uniform;

import std.typecons; //wrap
import std.traits; //ReturnType
import std.conv;

import std.stdio;

import deagle.graphics.GL;
import deagle.math.Matrix;
import deagle.math.Vector;


// Single Values
void send(T)(T val, int loc)
	if (is(T == float) || is(T == int) || is(T == uint))
{
	static if (is(T==float))
	{
		enum glTypeSpecifier = "f";
	}
	static if (is(T==int))
	{
		enum glTypeSpecifier = "i";
	}
	static if (is(T==uint))
	{
		enum glTypeSpecifier = "ui";
	}

	auto GL = GL();
	mixin("GL.Uniform1" ~ glTypeSpecifier ~ "(loc,val);");
}

// Vectors
void send(uint size, T)(Vector!(size,T) val, int loc)
	if ((is(T == float) || is(T == int) || is(T == uint))
			&& (2 <= size && size <= 4))
{
	// Type specifier
	static if (is(T==float))
	{
		enum glTypeSpecifier = "f";
	}
	static if (is(T==int))
	{
		enum glTypeSpecifier = "i";
	}
	static if (is(T==uint))
	{
		enum glTypeSpecifier = "ui";
	}

	// Arg List
	static if (size == 2)
	{
		enum argList = "(loc, val.x, val.y);";
	}
	static if (size == 3)
	{
		enum argList = "(loc, val.x, val.y, val.z);";
	}
	static if (size == 4)
	{
		enum argList = "(loc, val.x, val.y, val.z, val.w);";
	}


	auto GL = GL();
	mixin("GL.Uniform" ~ to!string(size) ~ glTypeSpecifier ~ argList);
}

unittest // Single value types (1 int, 1 float, etc.)
{
	import deagle.util.CallHistory;
	import derelict.opengl3.gl3;

	auto GL = GL();
	scope(exit) GL.history.clear();

	CallHistory history;
	
	int i = 5;
	i.send(0);
	history ~= Call.make!(glUniform1i)(0, 5);

	float f = 6.0f;
	f.send(1);
	history ~= Call.make!(glUniform1f)(1, 6.0);

	uint u = 7;
	u.send(2);
	history ~= Call.make!(glUniform1ui)(2, 7);

	assert(history == GL.history);
}

unittest // Vectors
{
	import deagle.util.CallHistory;
	import derelict.opengl3.gl3;

	auto GL = GL();
	scope(exit) GL.history.clear();

	CallHistory history;


	auto vec2f = new Vector!(2)();
	vec2f.send(0);
	history ~= Call.make!(glUniform2f)(0, 0.0, 0.0);

	auto vec2i = new Vector!(2, int)();
	vec2i.send(1);
	history ~= Call.make!(glUniform2i)(1, 0, 0);

	auto vec2u = new Vector!(2, uint)();
	vec2u.send(2);
	history ~= Call.make!(glUniform2ui)(2, 0, 0);

	auto vec3f = new Vector!(3)();
	vec3f.send(0);
	history ~= Call.make!(glUniform3f)(0, 0.0, 0.0, 0.0);

	auto vec3i = new Vector!(3, int)();
	vec3i.send(1);
	history ~= Call.make!(glUniform3i)(1, 0, 0, 0);

	auto vec3u = new Vector!(3, uint)();
	vec3u.send(2);
	history ~= Call.make!(glUniform3ui)(2, 0, 0, 0);


	auto vec4f = new Vector!(4)();
	vec4f.send(0);
	history ~= Call.make!(glUniform4f)(0, 0.0, 0.0, 0.0, 0.0);

	auto vec4i = new Vector!(4, int)();
	vec4i.send(1);
	history ~= Call.make!(glUniform4i)(1, 0, 0, 0, 0);

	auto vec4u = new Vector!(4, uint)();
	vec4u.send(2);
	history ~= Call.make!(glUniform4ui)(2, 0, 0, 0, 0);


	assert(GL.history == history);
}


// unittest // Matrices
// {

// 	import deagle.math.Matrix;

// 	auto m22f = new Matrix!(2,2)();
// 	m22f.send();

// 	auto m23f = new Matrix!(2,3)();
// 	m23f.send();

// 	auto m24f = new Matrix!(2,4)();
// 	m24f.send();
// }
