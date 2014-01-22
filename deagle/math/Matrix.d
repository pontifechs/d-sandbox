

module deagle.math.Matrix;

import std.traits; // isNumeric
import std.stdio; // writeln
import std.conv; //to!string

import deagle.math.Vector;

// A column-major square Matrix of type T of size size.
class Matrix(T = float, uint size = 4)
	if (isNumeric!(T) && size <= 4) // the size check is arbitrary
{
	private T[size * size] data;

	// Default matrix is the Identity
	this()
	{		
		data[] = 0;
		// fill in the diagonal with 1's
		for (uint ind = 0; ind < size; ++ind)
		{
			data[i(ind,ind)] = 1;
		}
	}

	// Fills the entire matrix with the given value
	this(T fill)
	{
		data[] = fill;
	}

	// Fill the array with arbitrary data
	this(T[size * size] arbitrary)
	{
		data = arbitrary.dup;
	}

	// Turns a 2d row,col index to a 1d array index.
	static private uint i(uint row, uint col)
	{
		return (col * size) + row;
	}	

	// Returns the element at the given row and column
  T opIndex(uint row, uint col)
	{
		return data[i(row,col)];
	}

	// Assigns the element at the given row and column
	T opIndexAssign(T val, uint row, uint col)
	{
		return data[i(row,col)] = val;
	}

	// toString for convenience;
	override string toString()
	{

		string ret = "";
		for (uint row = 0; row < size; ++row)
		{
			for (uint col = 0; col < size; ++col)
			{
				ret ~= to!string(data[i(row,col)]) ~ " ";
			}
			ret ~= "\n";
		}
		
		return ret;
	}

	// Equality
	override bool opEquals(Object o)
	{
		Matrix rhs = cast(Matrix)(o);
		return this.data == rhs.data;
	}
	

	Vector!(T, size) row(uint row)
	{
		// Build a vector from this row of the matrix
		T[size] rowVecData = 0;
		for (uint i = 0; i < size; ++i)
		{
			rowVecData[i] = data[this.i(row,i)];
		}
		return new Vector!(T, size)(rowVecData);
	} 

	Vector!(T, size) col(uint col)
	{
		T[size] colVecData = 0;
		for (uint i = 0; i < size; ++i)
		{
			colVecData[i] = data[this.i(i,col)];
		}
		return new Vector!(T, size)(colVecData);
	}

	// Matrix Multiply
	Matrix opBinary(string op)(Matrix rhs)
		if (op == "*")
	{
		T[size*size] newData = 0;

		// Iterate over each row/col		
		for (uint row = 0; row < size; ++row)
		{

			auto rowVec = this.row(row);
			
			for (uint col = 0; col < size; ++col)
			{
				auto colVec = rhs.col(col);
				
				newData[i(row,col)] = rowVec.dot(colVec);
			}
		}
		
		return new Matrix(newData);
	}

	
	// Matrix-Vector multiply
	Vector!(T, size) opBinary(string op)(Vector!(T, size) rhs)
	  if (op == "*")
	{
		T[size] newVec = 0;

		for (uint row = 0; row < size; ++row)
		{
			auto rowVec = this.row(row);
			
			newVec[row] = rowVec.dot(rhs);
		}

		return new Vector!(T, size)(newVec);
	}

}

unittest // Identity
{
	auto m = new Matrix!(float, 4)();

	// Check that the default is the identity
	assert(m.data.length == 4 * 4, 
				 "Wrong data length for float");
	assert(m.data == [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1], 
				 "Float default wasn't the identity");

}

unittest // Fill value
{
	auto m = new Matrix!(float, 4)(0);
	float[16] exp = 0;
	assert(m.data[] == exp, "Didn't fill properly");
}

unittest // Arbitrary fixed-size array
{
	float[9] exp = [1,2,3, 4,5,6, 7,8,9];

	auto m = new Matrix!(float, 3)(exp);
	assert(m.data == exp, "Arbitrary fixed array failed");
}

unittest // Indexing operations
{
	float[9] exp = [1,2,3, 4,5,6, 7,8,9];

	auto m = new Matrix!(float, 3)(exp);

	// Check multi-dimension indexing
	for (uint row = 0; row < 3; ++row)
	{
		for (uint col = 0; col < 3; ++col)
		{
			// Check index get first
			assert(m[row,col] == exp[m.i(row,col)], 
						 "Multi-dimension index failing at " ~ to!string(row) ~ to!string(col));

			// Change the index
			assert((m[row,col] = 99) == 99,
						 "Multi-dimension index assign not returning val");
			
			assert(m[row,col] == 99,
						 "Multi-dimension index assign failing");

		}
	}
}


unittest // row/col access
{
	float[9] exp = [1,2,3, 4,5,6, 7,8,9];
	
	auto m = new Matrix!(float, 3)(exp);

	assert(m.row(0) == new Vector!(float, 3)([1, 4, 7]), "Row 0 access failure");
	assert(m.row(1) == new Vector!(float, 3)([2, 5, 8]), "Row 1 access failure");
	assert(m.row(2) == new Vector!(float, 3)([3, 6, 9]), "Row 2 access failure");


	assert(m.col(0) == new Vector!(float, 3)([1, 2, 3]), "Col 0 access failure");
	assert(m.col(1) == new Vector!(float, 3)([4, 5, 6]), "Col 1 access failure");
	assert(m.col(2) == new Vector!(float, 3)([7, 8, 9]), "Col 2 access failure");
}


unittest // equality
{
	float[9] exp = [1,2,3, 4,5,6, 7,8,9];
	
	auto m1 = new Matrix!(float, 3)(exp);
	auto m2 = new Matrix!(float, 3)(0);
	auto m3 = new Matrix!(float, 3)(exp);
	
	assert(m1 == m3, "Equality failure");
	assert(m1 != m2, "Equality failure");
}

unittest // Matrix multiply
{
	auto I = new Matrix!(float, 3)();

	float[9] exp = [1,2,3, 4,5,6, 7,8,9];
	auto m1 = new Matrix!(float, 3)(exp);

	assert(I * I == I, "I * I Multiply Failure");

	assert(I * m1 == m1, "I * m != m");
	assert(m1 * I == m1, "m * I != m");

	float[9] expexp = [30, 36, 42, 66, 81, 96, 102, 126, 150];
	auto m1m1 = new Matrix!(float, 3)(expexp);

	assert(m1 * m1 == m1m1, "m1 * m1 != m2");
}

unittest // Matrix-Vector multiply
{
	auto I = new Matrix!(float, 3)();

	float[3] expV = [1,2,3];
	auto v = new Vector!(float, 3)(expV);

	assert(I * v == v, "I * v != v");

	float[9] expM = [1,2,3, 4,5,6, 7,8,9];
	auto m = new Matrix!(float, 3)(expM);

	assert(m * v == new Vector!(float, 3)([30, 36, 42]), "Matrix vector multiply fail");
	
}
