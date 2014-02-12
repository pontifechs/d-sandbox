module deagle.graphics.Uniform;

import std.typecons; //wrap
import std.traits; //ReturnType
import std.conv;

import std.stdio;


interface IUniform(DT)
	if (is(DT == float) || is(DT == int) || is(DT == uint))
{
	uint rows() const @property;
	uint cols() const @property;

	const(DT[]) data() const @property;

	final void send() // NVI
	{
		static if (is(DT==float))
		{
			string glTypeSpecifier = "f";
		}
		static if (is(DT==int))
		{
			string glTypeSpecifier = "i";
		}
		static if (is(DT==uint))
		{
			string glTypeSpecifier = "u";
		}

		// From the rows and columsn, figure out which uniform call needs to be made
		string call = "Uniform";
			
		// Vector
		if (this.cols == 1)
		{
			writeln(call, this.rows, glTypeSpecifier);
		}
		// Matrix
		else
		{

			if (this.cols == this.rows)
			{
				writeln(call, "Matrix", this.cols, glTypeSpecifier, "v");
			}
			else
			{
				writeln(call, "Matrix", this.cols, "x", this.rows, glTypeSpecifier, "v");
			}
		}
	}
}

// UFCS for single value types for float, int, and uint
uint rows(T)(T val) 
	if (is(T == float) || is(T == int) || is(T == uint))
{
	return 1;
}

uint cols(T)(T val) 
	if (is(T == float) || is(T == int) || is(T == uint))
{
	return 1;
}

const(T[]) data(T)(T val) 
	if (is(T == float) || is(T == int) || is(T == uint))
{
	return [val];
}

void send(T)(T val)
	if (is(T == float) || is(T == int) || is(T == uint))
{
	static if (is(T==float))
	{
		string glTypeSpecifier = "f";
	}
	static if (is(T==int))
	{
		string glTypeSpecifier = "i";
	}
	static if (is(T==uint))
	{
		string glTypeSpecifier = "u";
	}
	writeln("Uniform1", glTypeSpecifier);
}

// auto Uniform(T)(T obj)
// {
// 	alias DT = ReturnType!(obj.data);
// 	//return obj.wrap!(IUniform!(DT));
// 	return null;
// }


unittest // UFCS for single value types (1 int, 1 float, etc.)
{
	int bob = 5;
	bob.send();

	float f = 5.0f;
	f.send();

	uint i = 5;
	i.send();
}

unittest // Vectors
{
	import deagle.math.Vector;

	auto vec2f = new Vector!(2)();
	vec2f.send();

	auto vec3f = new Vector!(3)();
	vec3f.send();

	auto vec4f = new Vector!(4)();
	vec4f.send();


	auto vec2i = new Vector!(2, int)();
	vec2i.send();

	auto vec3i = new Vector!(3, int)();
	vec3i.send();

	auto vec4i = new Vector!(4, int)();
	vec4i.send();


	auto vec2u = new Vector!(2, uint)();
	vec2u.send();

	auto vec3u = new Vector!(3, uint)();
	vec3u.send();

	auto vec4u = new Vector!(4, uint)();
	vec4u.send();
}


unittest // Matrices
{

	import deagle.math.Matrix;

	auto m22f = new Matrix!(2,2)();
	m22f.send();

	auto m23f = new Matrix!(2,3)();
	m23f.send();

	auto m24f = new Matrix!(2,4)();
	m24f.send();
}
