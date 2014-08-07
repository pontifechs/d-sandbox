module deagle.math.Vector;

import std.math; //sqrt, trig, approxEqual
import std.traits; //__traits
import std.algorithm; // reduce, equal
import std.array; // array
import std.conv; // to!
import std.stdio;

import deagle.math.Matrix;

class Vector(uint size = 4, T = float) : Matrix!(1,size,T)
  if (isNumeric!(T) && size > 0)
{
	// Initialize all elements to 0
	this()
	{
		this.m_data[] = 0;
	}
	
	// Initialize all elements to fill
	this(T fill)
	{
		super(fill);
	}

	// Initialize with arbitrary elements
	this(T[size] arbitrary)
	{
		super(arbitrary);
	}

	// Returns the element at the given index
  public T opIndex(uint index) const
	{
		return m_data[index];
	}

	// Assigns the element at the given index
	T opIndexAssign(T val, uint index)
	{
		return m_data[index] = val;
	}
	
	// Named element accesses (x,y,z,w)
	static if (size >= 1)
	{
		@property T x() const
		{
			return m_data[0];
		}		
		@property T x(T val)
		{
			return m_data[0] = val;
		}
	}

	static if (size >= 2)
	{
		@property T y() const
		{
			return m_data[1];
		}		
		@property T y(T val)
		{
			return m_data[1] = val;
		}
	}

	static if (size >= 3)
	{
		@property T z() const
		{
			return m_data[2];
		}
		@property T z(T val)
		{
			return m_data[2] = val;
		}
	}

	static if (size >= 4)
	{
		@property T w() const
		{
			return m_data[3];
		}
		@property T w(T val)
		{
			return m_data[3] = val;
		}
	}

	// // Operator Overloads
	// // Equality
	// override bool opEquals(Object o) const
	// {
	// 	Vector rhs = to!(Vector)(o); // I'm sorry, but this is kinda stupid methinks.		
	// 	writeln(this);
	// 	writeln(rhs);
	// 	return equal!(approxEqual)(this.data[], rhs.data[]);
	// }

	// Plus, Minus
	Vector opBinary(string op)(Vector rhs) 
		if (op == "+" || op == "-")
	{
		T[size] newData = this.m_data.dup;
		
		for (uint i = 0; i < size; ++i)
		{
			mixin("newData[i] = newData[i] " ~ op ~ " rhs.m_data[i];");
		}
		return new Vector(newData);
	}
	
	// Multiply/Divide by scalar
	Vector opBinary(string op)(float rhs)
		if (op == "*" || op == "/")
	{
		T[size] newData = this.m_data.dup;
		
		for (uint i = 0; i < size; ++i)
		{
			mixin("newData[i] = newData[i] " ~ op ~ "rhs;");
		}

		return new Vector(newData);
	}

	// Length
	@property T length() const
	{
		T[size] squares = this.m_data[] * this.m_data[];
		// Casts are needed up and down for the nonreal types (int, uint)
		return cast(T)(sqrt(cast(float)(reduce!"a+b"(squares))));
	}

	Vector normalize()
	{
		// Divide out the length
		m_data[] /= this.length;
		return this;
	}

	// Dot product
	T dot(Vector rhs)
	{
		T[size] mult = this.m_data[] * rhs.m_data[];
		return reduce!("a+b")(mult);
	}

	// Inner product is really dot product
	T inner(Vector rhs)
	{
		return this.dot(rhs);
	}

	Matrix!(size,size,T) outer(Vector rhs)
	{
		// Thankfully enough, this already in column major order, so no issues there.
		auto cartProduct = cartesianProduct(this.m_data[], rhs.m_data[]);
	
		// Multiply each tuple value together
		T[size*size] cartProductMultMap = array(map!"a[0] * a[1]"(cartProduct));
	
		return new Matrix!(size,size,T)(cartProductMultMap);
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

		// Skew matrix
		public Matrix!(size,size,T) skew()
		{
			auto ret = new Matrix!(size,size,T)();
			ret[0,0] = 0;
			ret[0,1] = -this.z;
			ret[0,2] = this.y;

			ret[1,0] = this.z;
			ret[1,1] = 0;
			ret[1,2] = -this.x;

			ret[2,0] = -this.y;
			ret[2,1] = this.x;
			ret[2,2] = 0;
			return ret;
		}
	}	

	override string toString() const
	{
		return to!string(m_data);
	}
}


unittest // Default initialization
{
	auto v = new Vector!(3)();
	
	for (int i = 0; i < v.m_data.length; ++i)
	{
		assert(v.m_data[i] == 0, "Wrong defaults");
	}
}

unittest // Fill initialization
{
	auto v = new Vector!(4)(9);
	
	for (int i = 0; i < v.m_data.length; ++i)
	{
		assert(v.m_data[i] == 9, "Wrong fill");
	}
}

unittest // Arbitrary Initialization
{
	float[3] exp = [9,8,7];
	auto v = new Vector!(3)(exp);

	for (int i = 0; i < exp.length; ++i)
	{
		assert(v.m_data[i] == exp[i], "Wrong arbitrary init");
	}	
}

unittest // Index operations
{
	float[3] exp = [9,8,7];
	auto v = new Vector!(3)(exp);


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
	auto v = new Vector!(4)([1,2,3,4]);

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

	auto v1 = new Vector!(1)([1]);
	auto v2 = new Vector!(2)([1,2]);
	auto v3 = new Vector!(3)([1,2,3]);
	auto v4 = new Vector!(4)([1,2,3,4]);

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
	auto v1 = new Vector!(4)([1,2,3,4]);
	auto v2 = new Vector!(4)([4,3,2,1]);
	auto v3 = new Vector!(4)([1,2,3,4]);

	assert(v1 == v3, "Equality failure");
	assert(v1 != v2, "Inequality failure");
}

unittest // Addition, subtraction
{
	auto v1 = new Vector!(4)([1,2,3,4]);
	auto exp = new Vector!(4)([2,4,6,8]);

	// Add it together
	auto vAdd = v1 + v1;
	assert(vAdd == exp, "Add failure");
}

unittest // Multiply/Divide by scalar
{
	auto v1 = new Vector!(4)([1,2,3,4]);
	auto exp = new Vector!(4)([2,4,6,8]);
	
	// Multiply by 2
	auto vMult = v1 * 2;
	assert(vMult == exp, "Mult. Failure");
	
	// Divide by 2
	auto vDiv = vMult / 2;
	assert(vDiv == v1, "Div. Failure");
}

unittest // Length
{
	auto v1 = new Vector!(4)([1,2,3,4]);
	assert(v1.length == sqrt(1.0f + 4.0f + 9.0f + 16.0f), "length failure");
}

unittest // Normalize
{
	auto v = new Vector!(4)([1,2,3,4]);
	assert(approxEqual(v.normalize().length, 1), "Normalized doesn't have length 1");

}

unittest // 3-space dot
{
	auto v1 = new Vector!(4)([1,2,3,4]);
	
	assert(v1.dot(v1) == (1+4+9+16), "Dot failure");
	assert(v1.inner(v1) == (1+4+9+16), "Inner failure");
}

unittest // outer product
{
	auto v = new Vector!(3)([1,2,3]);
	
	auto exp = new Matrix!(3,3)([1,2,3, 2,4,6, 3,6,9]);

	assert(v.outer(v) == exp, "Outer product failure");

}

unittest // 3-space cross
{
	auto x = new Vector!(3)([1,0,0]);
	auto y = new Vector!(3)([0,1,0]);
	auto z = new Vector!(3)([0,0,1]);

	assert(x.cross(y) == z, "x * y != z");
	assert(y.cross(z) == x, "y * z != x");
	assert(z.cross(x) == y, "z * x != y");
}

unittest // Skew-symmetric
{
	// TODO:: Generate a bunch of these with matlab or octave or something
}

