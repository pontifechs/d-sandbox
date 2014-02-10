




class GL
{
public:
	
	static GL opCall(Flag!"Mock" mocked = No.Mock)
	{
		if (instance is null)
		{
			instance = new GL(mocked);
		}
		return instance;
	}


	// Dispatch all existing calls to their C binding.
	auto bopDispatch(string s, T...)(T args)
		if (is(typeof(&mixin("gl" ~ s)))) // Make sure the function exists
	{
		string fnName = "gl" ~ s;

		writeln(fullyQualifiedName!(mixin("gl"~s)));
		
		if (m_isMocked == No.Mock)
		{
			// Call the C binding
			mixin("return gl" ~ s ~ "(args);");    
		}
		else
		{
			// Add the arg list
			calls ~= new ArgumentList!(ParameterTypeTuple!(mixin("gl" ~ s)))(args);

			
			// Return the .init of the fn's return type (as long as it's not void)
			static if (!is(ReturnType!(mixin("gl" ~s)) == void))
			{
				return ReturnType!(mixin("gl" ~ s)).init;
			}
		}
	}

private:

	IArgumentList[] calls;

	this(Flag!"Mock" mocked)
	{
		m_isMocked = mocked;
	}
	

	static GL instance;
	Flag!"Mock" m_isMocked;

}


import std.typecons;
import std.stdio;
import std.traits;
import std.conv;

interface IArgumentList
{
}

class ArgumentList(T...) : IArgumentList
{
public:

	T args;

	this(T args)
	{
		this.args = args;
	}


	override bool opEquals(Object other)
	{
		auto rhs = cast(typeof(this)) other;
		if (rhs is null)
		{
			return false;
		}

		if (this.args.length != rhs.args.length)
		{
			return false;
		}
		
		// Iterate over each argument
		foreach (i, arg; this.args)
		{
			if (rhs.args[i] != arg)
			{
				return false;
			}
		}
		return true;
	}

	// toString
	override string toString() const
	{
		if (args.length == 0)
		{
			return "()";
		}
		
		string value="(";
		foreach (u; args)
		{
			value ~= to!string(u) ~ ", ";
		}
		return value[0..$-2] ~ ")";
	}
}


void glfoo(int i, int j, uint k, uint l) {}
void glbar() {}


void main()
{	


	auto GL = GL(Yes.Mock);

	GL.bopDispatch!"foo"(1,1,1,1);
	GL.bopDispatch!"foo"(1,1,1,1);
	GL.bopDispatch!"foo"(2,2,2,2);
	GL.bopDispatch!"bar"();



	writeln(GL.calls);

	assert(GL.calls[0] == GL.calls[1]);
	assert(GL.calls[1] != GL.calls[2]);
	assert(GL.calls[2] != GL.calls[3]);
}

