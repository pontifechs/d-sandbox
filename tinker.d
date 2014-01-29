module tinker;

import std.stdio;
import std.traits;

private string generateParameters(string myFuncInfo, func...)()
{
	alias ParameterStorageClass STC;
	alias ParameterStorageClassTuple!(func) stcs;
	enum nparams = stcs.length;

	string params = ""; // the result

	foreach (i, stc; stcs)
	{
		if (i > 0) params ~= ", ";

		// Parameter storage classes.
		if (stc & STC.scope_) params ~= "scope ";
		if (stc & STC.out_  ) params ~= "out ";
		if (stc & STC.ref_  ) params ~= "ref ";
		if (stc & STC.lazy_ ) params ~= "lazy ";

		// Take parameter type from the FuncInfo.
		params ~= format("%s.PT[%s]", myFuncInfo, i);

		// Declare a parameter variable.
		params ~= " " ~ PARAMETER_VARIABLE_ID!(i);
	}

	// Add some ellipsis part if needed.
	final switch (variadicFunctionStyle!(func))
	{
	case Variadic.no:
		break;

	case Variadic.c, Variadic.d:
		// (...) or (a, b, ...)
		params ~= (nparams == 0) ? "..." : ", ...";
		break;

	case Variadic.typesafe:
		params ~= " ...";
		break;
	}

	return params;
}

void foo(int a, int b)
{
	writeln(a,b);
}


void main()
{
	writeln(generateParameters("", ParameterTypeTuple!foo));
}
