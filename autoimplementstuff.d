
module tinker;

import std.stdio;
import std.typecons;
import std.conv;

struct Call
{
	string fnName = "";
	IArguments args = null;
}

// Empty interface to allow a non-templated member variable in Call (Slick)
interface IArguments
{
}

// Borrowed from DMocks-revived
template Arguments (U...)
{
	static if (U.length == 0) 
	{
		public class Arguments : IArguments
		{
			this () {}
			override bool opEquals (Object other) 
				{
					return cast(typeof(this)) other !is null;
				}

			override string toString () 
				{ 
					return "()"; 
				}
		}
	} 
	else 
    {
			class Arguments : IArguments
			{
				this (U args) 
					{ 
						Arguments = args; 
					}
            
				public U Arguments;
            
				override bool opEquals (Object other) 
					{
						auto args = cast(typeof(this)) other;
						if (args is null) return false;
						foreach (i, arg; Arguments) 
						{
							if (args.Arguments[i] != arg) 
							{
								return false;
							}
						}

						return true;
					}

				override string toString ()
					{ 
						string value = "(";
						foreach (u; Arguments) 
						{
							value ~= to!string(u) ~ ", ";
						}

						return value[0..$-2] ~ ")";
					}
			}
    }
}


// A class to be overridden
class Foo{
	// Since writeln can throw, we have to make any nothrow function final
	// There's probably a better way to determine whether or not this is the case
	// with some sort of __traits black magic
	final override size_t toHash() nothrow
		{
			return 0;
		}

	protected Call[] calls;
	
	void bar(int a) { }
}

// Prints log messages for each call to overridden functions.
string generateLogger(C, alias fun)() @property
{
	import std.traits;

	enum qname = C.stringof ~ "." ~ __traits(identifier, fun);
	string stmt;
	
	stmt ~= q{ struct Importer { import std.stdio; import tinker; import std.traits;} };

	stmt ~= `Importer.writeln("Log: ` ~ qname ~ `(", args, ")");`;
	stmt ~= `auto call = Importer.Call("` ~qname~ `", new Importer.Arguments!(Importer.ParameterTypeTuple!(self))(args));`;
	stmt ~= `calls ~= call;`;
	static if (is(ReturnType!fun == void))
		stmt ~= q{ parent(args); };
	else
		stmt ~= q{
			auto r = parent(args);
			Importer.writeln("--> ", r);
			return r;
		};

	return stmt;
}


// Logging wrapper around Base
template Logging(Base)
{
	import std.typecons;
	alias Logging = AutoImplement!(Base, generateLogger, always);
}

// Auto-implement everything
template always(alias f)
{
	enum always = true;
}

void main()
{
	auto foo = new Logging!Foo();
	foo.bar(13);

	writeln(foo.calls);
}
