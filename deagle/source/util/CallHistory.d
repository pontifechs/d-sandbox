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
		calls.clear();
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

	static Call somethingElse(alias Func, T...)(T args)
		if (is(typeof(Func) == function))		
	{
		// return Call(
		// 	__traits(identifier, Func),
		// 	fullyQualifiedName!(Func),
		// 	new ArgList!(ParameterTypeTuple!Func)(args));
		return Call();
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

	auto bob = Call.somethingElse!(foo)(1,2);
	
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



// unittest // Concatenation
// {
// 	CallHistory ch;
	
// 	auto same = ch ~ Call();
// 	assert(ch is same);
	
// 	ch ~= Call();
// 	assert(ch.calls.length == 2);
// }

// unittest // Equality (strict, ordered)
// {
// 	void fun(int i, int j) {}
// 	void gun() {}

// 	import std.traits;

// 	CallHistory foo;
// 	CallHistory bar;

// 	foo ~= Call();
// 	assert(foo != bar);

// 	bar ~= Call();
// 	assert(foo == bar);
	
// 	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
// 	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
// 	assert(foo == bar);

// 	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
// 	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
// 	assert(foo == bar);

// 	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
// 	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
// 	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
// 	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
// 	assert(foo == bar);

// 	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
// 	foo ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
// 	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!gun)());
// 	bar ~= Call("", "", new ArgList!(ParameterTypeTuple!fun)(1,2));
// 	assert(foo != bar);
// }

