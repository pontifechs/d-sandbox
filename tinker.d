module tinker;

import std.typecons;
import std.stdio;
import std.traits;

class Bar(uint rows, uint cols, T = float)
  if (isNumeric!(T) && rows > 0 && cols > 0)
{
	this() {}
}


class Foo(uint size, T = float) : Bar!(1,size,T)
  if (isNumeric!(T) && size > 0)
{

	this() {}
	
}


void ufcs(Foo!(2) val)
{
	writeln(val);
}


void main()
{
	
	auto bob = new Foo!(2,float)();
	bob.ufcs();

}

