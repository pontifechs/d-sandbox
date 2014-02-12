

module deagle.math.Matrix;

import std.traits; // isNumeric
import std.stdio; // writeln
import std.conv; //to!string
import std.math; // approxEqual
import std.algorithm; // equal

// TODO:: Once wrap can do NVI, we will want to get rid of this.
import deagle.graphics.Uniform;

// A column-major square Matrix of type T of size size.
class Matrix(uint colCt = 4, uint rowCt = 4, T = float) : IUniform!(T)
	if (isNumeric!(T) && colCt > 0 && rowCt > 0) // Only valid on numeric types
{
	// Data store
	protected T[colCt * rowCt] m_data;

	// Conform to IUniform interface (not explicitly for dependency reasons)
	public uint rows() const @property
	{
		return rowCt;
	}

	public uint cols() const @property 
	{
		return colCt;
	}
	
	public const(T[]) data() const @property
	{
		return this.m_data[];
	}
	
	// Default matrix is the Identity
	this()
	{		
		m_data[] = 0;
		// fill in the diagonal with 1's
		for (uint ind = 0; ind < rowCt && ind < colCt; ++ind)
		{
			m_data[i(ind,ind)] = 1;
		}
	}

	// Fills the entire matrix with the given value
	this(T fill)
	{
		m_data[] = fill;
	}

	// Fill the array with arbitrary data (Assumes Column-Major rder)
	this(T[colCt * rowCt] arbitrary)
	{
		m_data = arbitrary.dup;
	}

	// Turns a 2d row,col index to a 1d array index.
	static protected uint i(uint row, uint col)
	{
		return (col * rowCt) + row;
	}	

	// Returns the element at the given row and column
  T opIndex(uint row, uint col) const
	{
		return m_data[i(row,col)];
	}

	// Assigns the element at the given row and column
	T opIndexAssign(T val, uint row, uint col)
	{
		return m_data[i(row,col)] = val;
	}

	// toString for convenience;
	override string toString() const
	{

		string ret = "";
		for (uint row = 0; row < rows; ++row)
		{
			for (uint col = 0; col < cols; ++col)
			{
				ret ~= to!string(m_data[i(row,col)]) ~ " ";
			}
			ret ~= "\n";
		}
		
		return ret;
	}

	// Equality
	override bool opEquals(Object o) const
	{
		Matrix rhs = cast(Matrix)(o);
		return equal!(approxEqual)(this.m_data[], rhs.m_data[]);
	}
	
	// Return a colsx1 matrix (a row-vector)
	Matrix!(colCt, 1, T) row(uint row) const
	{
		// Build a vector from this row of the matrix
		T[colCt] rowVecData = 0;
		for (uint i = 0; i < cols; ++i)
		{
			rowVecData[i] = m_data[this.i(row,i)];
		}
		return new Matrix!(colCt, 1, T)(rowVecData);
	} 
	
	// Return a 1xrows matrix (a col-vector)
	Matrix!(1, rowCt, T) col(uint col) const
	{
		T[rowCt] colVecData = 0;
		for (uint i = 0; i < rows; ++i)
		{
			colVecData[i] = m_data[this.i(i,col)];
		}
		return new Matrix!(1, rowCt, T)(colVecData);
	}
	
	// Matrix Multiply
	Matrix!(rhsColCt, rowCt) opBinary(string op, uint rhsColCt, uint rhsRowCt, T)(Matrix!(rhsColCt, rhsRowCt, T) rhs) const
		if (op == "*")
	{
		static assert(colCt == rhsRowCt, "LHS matrix cols must equal RHS rows");

		//writeln(rowCt, " ", colCt, " ", rhsRowCt, " ", rhsColCt);

		T[rowCt * rhsColCt] newData = 0;

		// Iterate over each row/col		
		for (uint row = 0; row < rowCt; ++row)
		{
			auto rowVec = this.row(row);

		
			for (uint col = 0; col < rhsColCt; ++col)
			{
				auto colVec = rhs.col(col);

				// Dot the vectors together
				for (int rowrow = 0; rowrow < rowCt; ++rowrow)
				{

					newData[i(row,col)] += rowVec.m_data[rowrow] * colVec.m_data[rowrow];
				}



				// element-wise multiply, then add
				auto mults = new T[rowCt];
				mults[] = rowVec.m_data[] * colVec.m_data[];
				newData[i(row,col)] = reduce!"a+b"(mults);
			}
		}
		return new Matrix!(rhsColCt, rowCt)(newData);
	}
	
	// matrix addition
	Matrix opBinary(string op)(Matrix rhs) const
		if (op == "+")
	{
		T[rowCt*colCt] newData = this.m_data;
		newData[] = this.m_data[] + rhs.m_data[];
		return new Matrix(newData);
	}

	// Multiply matrix by constant
	Matrix opBinary(string op)(T rhs) const
		if (op == "*")
	{
		T[rowCt*colCt] newData = this.m_data;
		newData[] *= rhs;
		return new Matrix(newData);
	}
}

unittest // Identity
{
	auto m44 = new Matrix!();

	// Check that the default is the identity
	assert(m44.m_data.length == 4 * 4, 
				 "Wrong data length for 4x4");
	assert(m44.m_data == [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1], 
				 "4x4 default wasn't the identity");

	
	auto m24 = new Matrix!(2,4)();
	
	// Check that the default is the identity
	assert(m24.m_data.length == 2 * 4, 
				 "Wrong data length for 4x4");
	assert(m24.m_data == [1,0,0,0, 0,1,0,0],
				 "2x4 default wasn't the identity");

	auto m42 = new Matrix!(4,2)();
	
	// Check that the default is the identity
	assert(m42.m_data.length == 4 * 2,
				 "Wrong data length for 4x4");
	assert(m42.m_data == [1,0, 0,1, 0,0, 0,0],
				 "2x4 default wasn't the identity");

}

unittest // Fill value
{
	auto m44 = new Matrix!(4,4)(0);
	float[4*4] expM44 = 0;
	assert(m44.m_data[] == expM44, "Didn't fill properly 4x4");

	auto m24 = new Matrix!(2,4)(0);
	float[2*4] expM24 = 0;
	assert(m24.m_data[] == expM24, "Didn't fill properly 2x4");

	auto m42 = new Matrix!(4,2)(0);
	float[4*2] expM42 = 0;
	assert(m42.m_data[] == expM42, "Didn't fill properly 4x2");

}

unittest // Arbitrary fixed-size array
{
	float[3*3] expM33 = [1,2,3, 4,5,6, 7,8,9];

	auto m33 = new Matrix!(3,3)(expM33);
	assert(m33.m_data == expM33, "Arbitrary fixed array failed");

	float[3*5] expM35 = [1,2,3,4,5, 6,7,8,9,10, 11,12,13,14,15];

	auto m35 = new Matrix!(3,5)(expM35);
	assert(m35.m_data == expM35, "Arbitrary fixed array failed");

	float[5*3] expM53 = [1,2,3, 4,5,6, 7,8,9, 10,11,12, 13,14,15];

	auto m53 = new Matrix!(5,3)(expM53);
	assert(m53.m_data == expM53, "Arbitrary fixed array failed");
}

unittest // Indexing operations
{
	float[9] exp = [1,2,3, 4,5,6, 7,8,9];

	auto m = new Matrix!(3,3)(exp);

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
	
	auto m = new Matrix!(3,3)(exp);

	assert(m.row(0) == new Matrix!(3,1)([1, 4, 7]), "Row 0 access failure");
	assert(m.row(1) == new Matrix!(3,1)([2, 5, 8]), "Row 1 access failure");
	assert(m.row(2) == new Matrix!(3,1)([3, 6, 9]), "Row 2 access failure");


	assert(m.col(0) == new Matrix!(1,3)([1, 2, 3]), "Col 0 access failure");
	assert(m.col(1) == new Matrix!(1,3)([4, 5, 6]), "Col 1 access failure");
	assert(m.col(2) == new Matrix!(1,3)([7, 8, 9]), "Col 2 access failure");
}


unittest // equality
{
	float[9] exp = [1,2,3, 4,5,6, 7,8,9];
	
	auto m1 = new Matrix!(3,3)(exp);
	auto m2 = new Matrix!(3,3)(0);
	auto m3 = new Matrix!(3,3)(exp);
	
	assert(m1 == m3, "Equality failure");
	assert(m1 != m2, "Equality failure");
}

unittest // Matrix multiply
{
	auto I = new Matrix!(3, 3)();

	float[3*3] exp = [1,2,3, 4,5,6, 7,8,9];
	auto m1 = new Matrix!(3, 3)(exp);

	assert(I * I == I, "I * I Multiply Failure");

	assert(I * m1 == m1, "I * m != m");
	assert(m1 * I == m1, "m * I != m");

	float[9] expexp = [30, 36, 42, 66, 81, 96, 102, 126, 150];
	auto m1m1 = new Matrix!(3, 3)(expexp);

	assert(m1 * m1 == m1m1, "m1 * m1 != m2");
}

unittest // Matrix-constant multiply
{
	auto I = new Matrix!(3,3)();

	float[9] exp = [9,0,0, 0,9,0, 0,0,9];
	auto expI = new Matrix!(3,3)(exp);

	assert(I * 9 == expI, "Matrix/Constant failure");
	
	float[9] ones = [1,1,1, 1,1,1, 1,1,1];
	float[9] nines = [9,9,9, 9,9,9, 9,9,9];
	auto m = new Matrix!(3,3)(ones);
	auto expM = new Matrix!(3,3)(nines);
	
	assert(m * 9 == expM, "Matrix/Constant failure");

}

