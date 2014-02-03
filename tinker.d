
import std.typecons; //wrap

import std.stdio;


abstract class FooBar
{
public:
	void foo();
	void bar();

	final void both() // NVI
		{
			foo();
			bar();
		}
}

class Baz
{
public:
	void foo() { writeln("foo"); }
	void bar() { writeln("bar"); }
}

void main()
{
	auto baz = new Baz();
	auto foobar = baz.wrap!(FooBar)(); 
  // causes this wall-o-text error http://pastebin.com/Pa5dHQtN
	// Which at the end says:

	// /usr/local/Cellar/dmd/2.064.2/import/std/typecons.d(2779): Error: static assert  "Source Baz does not have structural conformance to (FooBar)"

}
