module deagle.math.Vector;

import std.math; //sqrt, trig
import std.traits; //__traits
import std.algorithm; // reduce
import std.array; // array
import std.conv; // to!string
import std.stdio;

import deagle.math.Matrix;

class Vector(T = float, uint size = 4)
	if (isNumeric!(T) && size <= 4) // the size check is arbitrary
{
	private T[size] data;

	// Initialize all elements to 0
	this()
	{
		data[] = 0;
	}
	
	// Initialize all elements to fill
	this(T fill)
	{
		data[] = fill;
	}

	// Initialize with arbitrary elements
	this(T[size] arbitrary)
	{
		data = arbitrary.dup; // not sure if that's needed or not.
	}

	// Returns the element at the given index
  T opIndex(uint index)
	{
		return data[index];
	}

	// Assigns the element at the given index
	T opIndexAssign(T val, uint index)
	{
		return data[index] = val;
	}
	
	// Named element accesses (x,y,z,w)
	static if (size >= 1)
	{
		@property T x()
		{
			return data[0];
		}		
		@property T x(T val)
		{
			return data[0] = val;
		}
	}

	static if (size >= 2)
	{
		@property T y()
		{
			return data[1];
		}		
		@property T y(T val)
		{
			return data[1] = val;
		}
	}

	static if (size >= 3)
	{
		@property T z()
		{
			return data[2];
		}
		@property T z(T val)
		{
			return data[2] = val;
		}
	}

	static if (size >= 4)
	{
		@property T w()
		{
			return data[3];
		}
		@property T w(T val)
		{
			return data[3] = val;
		}
	}

	// Operator Overloads
	// Equality
	override bool opEquals(Object o)
	{
		Vector rhs = cast(Vector)o; // I'm sorry, but this is kinda stupid methinks.
		return this.data == rhs.data;
	}

	// Plus, Minus
	Vector opBinary(string op)(Vector rhs) 
		if (op == "+" || op == "-")
	{
		T[size] newData = this.data.dup;
		
		for (uint i = 0; i < size; ++i)
		{
			mixin("newData[i] = newData[i] " ~ op ~ " rhs.data[i];");
		}

		return new Vector(newData);
	}
	
	// Multiply/Divide by scalar
	Vector opBinary(string op)(float rhs)
		if (op == "*" || op == "/")
	{
		T[size] newData = this.data.dup;
		
		for (uint i = 0; i < size; ++i)
		{
			mixin("newData[i] = newData[i] " ~ op ~ "rhs;");
		}

		return new Vector(newData);
	}

	// Length
	@property T length()
	{
		T[size] squares = this.data[] * this.data[];
		return sqrt(reduce!"a+b"(squares));
	}

	void normalize()
	{
		// Divide out the length
		data[] /= this.length;
	}

	// Dot product
	T dot(Vector rhs)
	{
		T[size] mult = this.data[] * rhs.data[];
		return reduce!("a+b")(mult);
	}

	// Inner product is really dot product
	T inner(Vector rhs)
	{
		return this.dot(rhs);
	}

	static if (size >=1 )
	{
		Matrix!(T,size) outer(Vector rhs)
		{
			// Thankfully enough, this already in column major order, so no issues there.
			auto cartProduct = cartesianProduct(this.data[], rhs.data[]);
	
			// Multiply each tuple value together
			T[size*size] cartProductMultMap = array(map!"a[0] * a[1]"(cartProduct));
	
			return new Matrix!(T, size)(cartProductMultMap);
		}
	}

	// Cross product (only defined in 3-space)
	static if (size == 3)
	{
		Vector cross(Vector rhs)
		{
			T newX = (this.y * rhs.z) - (this.z * rhs.y);
			T newY = (this.z * rhs.x) - (this.x * rhs.z);
			T newZ = (this.x * rhs.y) - (this.y * rhs.x);
			return new Vector([newX, newY, newZ]);
		}
	}	

	override string toString()
	{
		return to!string(data);
	}
	
}


unittest // Default initialization
{
	auto v = new Vector!(float, 3)();
	
	for (int i = 0; i < v.data.length; ++i)
	{
		assert(v.data[i] == 0, "Wrong defaults");
	}
}


unittest // Fill initialization
{
	auto v = new Vector!(float, 4)(9);
	
	for (int i = 0; i < v.data.length; ++i)
	{
		assert(v.data[i] == 9, "Wrong fill");
	}
}

unittest // Arbitrary Initialization
{
	float[3] exp = [9,8,7];
	auto v = new Vector!(float, 3)(exp);

	for (int i = 0; i < exp.length; ++i)
	{
		assert(v.data[i] == exp[i], "Wrong arbitrary init");
	}	

}

unittest // Index operations
{
	float[3] exp = [9,8,7];
	auto v = new Vector!(float, 3)(exp);


	for (int i = 0; i < exp.length; ++i)
	{
		// Check index get
		assert(v[i] == exp[i], "Wrong index get");
		
		// Change index
		assert((v[i] = 99) == 99, "Wrong index set return");
		
		// Check index via get
		assert(v[i] == 99, "Wrong index set change");		
	}
}

unittest // named element access (x,y,z,, etc.
{
	auto v = new Vector!(float, 4)([1,2,3,4]);

	// Get
	assert(v.x == 1, "Named element access Failed x");
	assert(v.y == 2, "Named element access Failed y");
	assert(v.z == 3, "Named element access Failed z");
	assert(v.w == 4, "Named element access Failed w");

	// Set return
	assert((v.x = 4) == 4, "Named element set return failed x");
	assert((v.y = 3) == 3, "Named element set return failed y");
	assert((v.z = 2) == 2, "Named element set return failed z");
	assert((v.w = 1) == 1, "Named element set return failed w");

	// Set value
	assert(v.x == 4, "Named element set value Failed x");
	assert(v.y == 3, "Named element set value Failed x");
	assert(v.z == 2, "Named element set value Failed x");
	assert(v.w == 1, "Named element set value Failed x");
}

unittest // Named elements don't appear larger than the vector they're on
{

	auto v1 = new Vector!(float,1)([1]);
	auto v2 = new Vector!(float,2)([1,2]);
	auto v3 = new Vector!(float,3)([1,2,3]);
	auto v4 = new Vector!(float,4)([1,2,3,4]);

	// Check that we can't access letters that don't exist
	assert(!__traits(compiles, v1.y), "bad Y prop include");
	assert(!__traits(compiles, v1.z), "bad Z prop include");
	assert(!__traits(compiles, v1.w), "bad W prop include");

	assert(!__traits(compiles, v2.z), "bad Z prop include");
	assert(!__traits(compiles, v2.w), "bad W prop include");

	assert(!__traits(compiles, v3.w), "bad W prop include");	
}


unittest // Equality
{
	auto v1 = new Vector!(float, 4)([1,2,3,4]);
	auto v2 = new Vector!(float, 4)([4,3,2,1]);
	auto v3 = new Vector!(float, 4)([1,2,3,4]);

	assert(v1 == v3, "Equality failure");
	assert(v1 != v2, "Inequality failure");
}

unittest // Addition, subtraction
{
	auto v1 = new Vector!(float, 4)([1,2,3,4]);
	auto exp = new Vector!(float, 4)([2,4,6,8]);

	// Add it together
	auto vAdd = v1 + v1;
	assert(vAdd == exp, "Add failure");
}

unittest // Multiply/Divide by scalar
{
	auto v1 = new Vector!(float, 4)([1,2,3,4]);
	auto exp = new Vector!(float, 4)([2,4,6,8]);
	
	// Multiply by 2
	auto vMult = v1 * 2;
	assert(vMult == exp, "Mult. Failure");
	
	// Divide by 2
	auto vDiv = vMult / 2;
	assert(vDiv == v1, "Div. Failure");
}

unittest // Length
{
	auto v1 = new Vector!(float, 4)([1,2,3,4]);
	assert(v1.length == sqrt(cast(float)(1 + 4 + 9 + 16)), "length failure");
}

unittest // 3-space dot
{
	auto v1 = new Vector!(float, 4)([1,2,3,4]);
	
	assert(v1.dot(v1) == (1+4+9+16), "Dot failure");
	
}

unittest // 3-space cross
{
	auto x = new Vector!(float, 3)([1,0,0]);
	auto y = new Vector!(float, 3)([0,1,0]);
	auto z = new Vector!(float, 3)([0,0,1]);

	assert(x.cross(y) == z, "x * y != z");
	assert(y.cross(z) == x, "y * z != x");
	assert(z.cross(x) == y, "z * x != y");
}

unittest // Outer product
{
	auto v1 = new Vector!(float, 3)([1,1,1]);
	auto v2 = new Vector!(float, 3)([1,2,3]);

	auto exp = new Matrix!(float, 3)([1,1,1,2,2,2,3,3,3]);

	assert(v1.outer(v2) == exp, "outer product failure");
}
