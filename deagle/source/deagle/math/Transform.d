module deagle.math.Transform;

import deagle.math.Matrix;
import deagle.math.Vector;

import std.math; // Trig
import std.conv; // to!string (invariant)
import std.typecons; // Tuple
import std.stdio;

alias Vector!(3, float) Vec3;

// A 3D transform matrix is always a 4x4, 2D 3x3
class Transform(uint dimension) : Matrix!(dimension + 1, dimension + 1, float)
  if (dimension == 3 || dimension == 2)
{
	
	// Default to the Identity (No-op transform)
	this()
	{
		super();
	}
	
	// Construct from rotation kernel
	this(Matrix!(dimension, dimension) rotationKernel)
	{
		super();
		
		for (int row = 0; row < dimension; row++)
		{
			for (int col = 0; col < dimension; col++)
			{
				this[row,col] = rotationKernel[row,col];
			}
		}
	}

	public bool orthogonal() @property
	{
		// 2. Rotation kernel is an orthogonal basis
		auto x = Vector!(3)([this[0,0], this[1,0], this[2,0]]);
		auto y = Vector!(3)([this[0,1], this[1,1], this[2,1]]);
		auto z = Vector!(3)([this[0,2], this[1,2], this[2,2]]);

		return ((x.cross(y) == z) && (z.cross(x) == y) && (y.cross(z) == x));
	}

	
	// Axis-Angle formulation
	static Transform!3 rotate(Vector!(3) axis, float angle)
	{
		// Rk(theta) = C(theta)I + V(theta)kk^T + S(theta)skew(k)
		auto I = new Matrix!(3,3)();

		float cosTheta = cos(angle);
		float versTheta = 1 - cosTheta;
		float sinTheta = sin(angle);
		
		auto rotationKernel = (I * cosTheta) + 
			(axis.outer(axis) * versTheta) + 
			(axis.skew() * sinTheta); 

		return new Transform!3(rotationKernel);
	}

	// Rotate around X
	static Transform!3 rotateX(float theta)
	{

		auto ret = new Transform!3();
		import std.stdio;
		float cosTheta = cos(theta);
		float sinTheta = sin(theta);
		ret.m_data[i(1, 1)] = cosTheta;
		ret.m_data[i(1, 2)] = -sinTheta;
		ret.m_data[i(2, 1)] = sinTheta;
		ret.m_data[i(2, 2)] = cosTheta;

		return ret;
	}

	// Rotate around Y
	static Transform!3 rotateY(float theta)
	{
		auto ret = new Transform!3();
		float cosTheta = cos(theta);
		float sinTheta = sin(theta);
		ret.m_data[i(0, 0)] = cosTheta;
		ret.m_data[i(0, 2)] = sinTheta;
		ret.m_data[i(2, 0)] = -sinTheta;
		ret.m_data[i(2, 2)] = cosTheta;
		return ret;
	}

	// Rotate around Z
	static Transform!3 rotateZ(float theta)
	{
		auto ret = new Transform!3();
		float cosTheta = cos(theta);
		float sinTheta = sin(theta);
		ret.m_data[i(0, 0)] = cosTheta;
		ret.m_data[i(0, 1)] = -sinTheta;
		ret.m_data[i(1, 0)] = sinTheta;
		ret.m_data[i(1, 1)] = cosTheta;
		return ret;
	}


	// Translate
	static Transform!3 translate(Vec3 trans)
	{
		auto ret = new Transform!3();
		ret[0,3] = trans.x;
		ret[1,3] = trans.y;		
		ret[2,3] = trans.z;
		return ret;
	}

	// Scale
	static Transform!3 scale(Vec3 scale)
	{		
		auto ret = new Transform!3();
		ret[0,0] = scale.x;
		ret[1,1] = scale.y;
		ret[2,2] = scale.z;
		return ret;
	}

	// View
	static Transform!3 view(Vec3 eye, Vec3 point, Vec3 up)
	{
		return null;
	}

	// Projection
	static Transform!3 projection(float fov, float aspect, float near, float far)
	{
		return null;
	}
}


unittest // From rotation kernel
{
	auto rot = new Matrix!(3,3)([0,0,1, 0,1,0, 1,0,0]);
	
	auto transform = new Transform!(3)(rot);
	
	for (int row = 0; row < 3; row++)
	{
		for (int col = 0; col < 3; col++)
		{
			assert(rot[row,col] == transform[row,col] ,"Rotation kernel not transferred");
		}
	}
	
}

unittest // orthogonal
{
	// TODO:: Generate some of these with matlab/octave
}

unittest // angle, axis to rot
{
	// TODO:: Generate some of these with matlab/octave
}

unittest // rot to angle,axis
{
	// TODO:: Generate some of these with matlab/octave
}


unittest // Rotate* by 2PI is no-op
{
	auto I = new Matrix!(4,4);

	auto rX = Transform!3.rotateX(2*PI);
	auto rY = Transform!3.rotateY(2*PI);
	auto rZ = Transform!3.rotateZ(2*PI);
	
	assert(I == rX, "RotateX by 2PI is non-identity");
	assert(I == rY, "RotateY by 2PI is non-identity");
	assert(I == rZ, "RotateZ by 2PI is non-identity");
}

unittest // Any Rotate combined with Identity is the rotate
{
	import std.random;

	auto gen = Random(0);

	auto I = new Matrix!(4,4);

	foreach (i; 0..100)
	{
		float a = uniform(0.0f, 2*PI, gen);	
		auto rX = Transform!3.rotateX(a);
	  auto rY = Transform!3.rotateY(a);
		auto rZ = Transform!3.rotateZ(a);

		assert(rX * I == rX, "RotateX by " ~ to!string(a) ~ " * I != rX");
		assert(rY * I == rY, "RotateY by " ~ to!string(a) ~ " * I != rY");
		assert(rZ * I == rZ, "RotateZ by " ~ to!string(a) ~ " * I != rZ");
	}
}

unittest // Scale
{
	import std.random;
	auto gen = Random(0);
	
	foreach (i; 0..100)
	{
		float a1 = uniform(0.0f, 10.0f, gen);
		float a2 = uniform(0.0f, 10.0f, gen);
		float a3 = uniform(0.0f, 10.0f, gen);
		auto toScale = Vector!(4)([a1, a2, a3, 1.0f]);

		float s1 = uniform(0.0f, 10.0f, gen);
		float s2 = uniform(0.0f, 10.0f, gen);
		float s3 = uniform(0.0f, 10.0f, gen);
		auto scaleVec = Vector!(3)([s1, s2, s3]);

		auto scale = Transform!3.scale(scaleVec);

		auto expScaled = Vector!(4)([a1*s1, a2*s2, a3*s3, 1.0f]);

		Vector!(4) bob = scale * toScale;

		assert(bob == expScaled, "Scale incorrect");
	}
}
 
unittest // Translate
{
	import std.random;
	auto gen = Random(0);
	
	foreach (i; 0..100)
	{
		float a1 = uniform(0.0f, 10.0f, gen);
		float a2 = uniform(0.0f, 10.0f, gen);
		float a3 = uniform(0.0f, 10.0f, gen);
		auto toTrans = Vector!(4)([a1, a2, a3, 1.0f]);

		float t1 = uniform(0.0f, 10.0f, gen);
		float t2 = uniform(0.0f, 10.0f, gen);
		float t3 = uniform(0.0f, 10.0f, gen);
		auto transVec = Vector!(3)([t1, t2, t3]);

		auto trans = Transform!3.translate(transVec);
		
		auto expTransed = Vector!(4)([a1+t1, a2+t2, a3+t3, 1.0f]);
		assert(trans * toTrans == expTransed, "Trans incorrect");
	}
}

