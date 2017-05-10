module deagle.util.CallHistory;


import std.conv;
import std.traits;


struct CallHistory
{

public:
	
	// Index access
	const(Call) opIndex(uint index) const
	{
		return calls[index];
	}

	// Clear
	void clear()
	{
		calls = [];
	}

	ulong length() const @property
	{
		return calls.length;
	}

	// Concatenation ops (with call only)
	CallHistory opBinary(string op)(Call rhs)
		if (op == "~")
	{
		calls ~= rhs;
		return this;
	}

	// ~=
	CallHistory opOpAssign(string op)(Call rhs)
		if (op == "~")
	{
		return this ~ rhs;
	}

private:
	Call[] calls;

}


struct Call
{
	string functionName;       	// The function name
	string qualifiedName;  // The fully qualified name
	IArgList argList;      // The arguments

	static Call make(alias Func, T...)(T args)
		if (__traits(compiles, Func(args))) // If I can call Func with args
	{
		return Call(
			__traits(identifier, Func),
			fullyQualifiedName!(Func),
			new ArgList!(ParameterTypeTuple!Func)(args));
		// return Call();
	}
}

interface IArgList {}
class ArgList(T...) : IArgList
{
public:

	T args;

	this(T args)
	{
		this.args = args;
	}

	// Equality
	override bool opEquals(Object other) const
	{
		auto rhs = cast(typeof(this)) other;
		if (rhs is null) { return false; }
		
		// Make sure we have the same number of arguments
		if (this.args.length != rhs.args.length)
		{
			return false;
		}
		
		// Check each argument for equality
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
		else
		{
			string value="(";
			foreach (u; args)
			{
				value ~= to!string(u) ~ ", ";
			}
			return value[0..$-2] ~ ")";
		}
	}
}

unittest // ArgList equality
{
	import std.stdio;

	void foo(int i, int j) {}
	void bar() {}
	
	auto oneTwo = new ArgList!(ParameterTypeTuple!foo)(1,2);
	auto oneTwoAgain = new ArgList!(ParameterTypeTuple!foo)(1,2);
	auto notEqual = new ArgList!(ParameterTypeTuple!foo)(2,3);

	assert(oneTwo == oneTwoAgain);
	assert(oneTwo != notEqual);
	assert(oneTwoAgain != notEqual);

	auto barCall = new ArgList!(ParameterTypeTuple!bar)();
	auto barCallAgain = new ArgList!(ParameterTypeTuple!bar)();
	
	assert(barCall == barCallAgain);
	assert(oneTwo != barCall);
}

unittest // Concatenation
{
	CallHistory ch;
	
	auto same = ch ~ Call();
	assert(ch is same);
	
	ch ~= Call();
	assert(ch.calls.length == 2);
}

unittest // Equality (strict, ordered)
{
	void fun(int i, int j) {}
	void gun() {}

	import std.traits;

	CallHistory foo;
	CallHistory bar;

	foo ~= Call();
	assert(foo != bar);

	bar ~= Call();
	assert(foo == bar);
	
	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
	assert(foo == bar);

	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
	assert(foo == bar);

	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
	assert(foo == bar);

	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
	assert(foo != bar);
}



unittest // Call.make
{
	import std.stdio;

	import derelict.opengl3.gl3;
	
	// Use std.stdio.chunks for convenience
	// (using a scoped function declaration gives some strange error);
	auto bob = Call.make!(chunks)(stdin, 1024);
	
	auto bobArgList = new ArgList!(ParameterTypeTuple!chunks)(stdin, 1024);
	auto bobName = "chunks";
	auto bobQualifiedName = "std.stdio.chunks";


	assert(bob.argList == bobArgList);
	assert(bob.functionName == bobName);
	assert(bob.qualifiedName == bobQualifiedName);

	enum nks = "nks";
	auto mixinBob = Call.make!(mixin("chu" ~ nks))(stdin, 1024);

	assert(mixinBob.argList == bobArgList);
	assert(mixinBob.functionName == bobName);
	assert(mixinBob.qualifiedName == bobQualifiedName);

	auto clearColor = Call.make!(glClearColor)(0.2, 0.2, 0.2, 1.0);

}




