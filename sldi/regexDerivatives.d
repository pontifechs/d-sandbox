module regexDerivatives;

import std.stdio;


// Pattern matching from Regex tree
abstract class Regex
{
public:



	bool match(string haystack)
	{
		// Base case -- (pulled all of the characters off the string
		// If the empty string is still in the language (ie isNullable), we accept.
		if (haystack.length == 0)
		{
			return this.nullable();
		}
		// Recursvie case -- (derive the languages with respect to the first character)
		else
		{
			return this.derive(haystack[0]).match(haystack[1..$]);
		}
	}

	abstract Regex derive(char c);

	abstract bool nullable()  @property;
}

// Empty Set Language {}
class Empty : Regex
{
public:
	override Regex derive(char c)
	{
		// Deriving the empty set results in the empty set.
		return new Empty();
	}

	override bool nullable() @property
	{
		// Empty set by definition does not contain the empty string
		return false;
	}

	override string toString()
	{
		return "{}";
	}
}


class Epsilon : Regex
{
public:
	override Regex derive(char c)
	{
		// since the only string in the empty string language is the empty string
		// it disappears during the filter step (doesn't start with any char)
		return new Empty();
	}

	override bool nullable() @property
	{ 
		// By definition, contains the empty string.
		return true; 
	}

	override string toString()
	{
		return "{\"\"}";
	}
}

// Language containing the single character string : {"c"}
class Primitive : Regex
{
private:
	char c;

public:
	this(char c) { this.c = c;}

	override Regex derive(char c)
	{
		// If this primitive is the language of c, the filter keeps it, then removes the character.
		if (this.c == c)
		{
			return new Epsilon();
		}
		// Otherwise, the filter step removes it, leaving just the empty set.
		else
		{
			return new Empty();
		}
	}

	// By definition, this only contains the string "c", which precludes the empty string.
	override bool nullable() @property
	{
		return false;
	}

	override string toString()
	{
		return "{'" ~ c ~ "'}";
	}
}


class Union : Regex
{
private:
	Regex lhs;
	Regex rhs;

public:
	this(Regex lhs, Regex rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
	}

	// Since all strings in both lhs and rhs are in lhs U rhs, both lhs and rhs need to be derived.
	override Regex derive(char c)
	{
		return new Union(lhs.derive(c), rhs.derive(c));
	}

	// It's nullable if either languages are nullable
	override bool nullable() @property
	{
		return lhs.nullable || rhs.nullable;
	}

	override string toString()
	{
		return "(" ~ lhs.toString() ~ " U " ~ rhs.toString() ~ ")";
	}
}

class Star : Regex
{
private:
	Regex lang;

public:
	this(Regex lang)
	{
		this.lang = lang;
	}

	// Pull one of the repetitions off, derive it, and then concat it back to the rest( still L*)
	override Regex derive(char c)
	{
		return new Concat(lang.derive(c), new Star(lang));
	}

	// Contains the empty string by definition (L^0 = {""})
	override bool nullable() @property
	{
		return true;
	}

	override string toString()
	{
		return "(" ~ lang.toString() ~ ")*";
	}
}

// Concatenation of two languages (lhs ~ rhs)
class Concat : Regex
{
private:
	Regex lhs;
	Regex rhs;

public:
	this(Regex lhs, Regex rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
	}

	// The trickiest of them all
	override Regex derive(char c)
	{
		auto lhsPrime = new Concat(lhs.derive(c), rhs);

		// If lhs is nullable (contains empty string), when we concatenate with rhs, the strings in rhs will
		// also need to be derived.
		if (lhs.nullable)
		{
			return new Union(lhsPrime, rhs.derive(c));
		}
		else
		{
			return lhsPrime;
		}
	}

	// In order for the empty string to remain in the concatenated language,
	// it must appear in both sides of the concat.
	override bool nullable() @property
	{
		return lhs.nullable && rhs.nullable;
	}

	override string toString()
	{
		return "(" ~ lhs.toString() ~ " ~ " ~ rhs.toString() ~ ")";
	}
}

class Complement : Regex
{
private:
	Regex lang;

public:
	this(Regex lang)
	{
		this.lang = lang;
	}

	override Regex derive(char c)
	{
		return new Complement(lang.derive(c));
	}

	// If the empty string is in lang, it won't be in lang's complement, by definition.
	override bool nullable() @property
	{
		return !lang.nullable();
	}

	override string toString()
	{
		return "~(" ~ lang.toString() ~ ")";
	}
}

class Intersect : Regex
{
private:
	Regex lhs;
	Regex rhs;

public:
	this(Regex lhs, Regex rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
	}

	override Regex derive(char c)
	{
		return new Intersect(lhs.derive(c), rhs.derive(c));
	}

	// "" must be in both sides to appear in the resulting intersection
	override bool nullable() @property
	{
		return lhs.nullable && rhs.nullable;
	}

	override string toString()
	{
		return "(" ~ lhs.toString() ~ " ^ " ~ rhs.toString() ~ ")";
	}
}

// Start with Primitive, as Empty and Epsilon are trivial.
unittest // Primitive
{
	auto c = new Primitive('c');

	assert(c.match("c"), "Primitive didn't match the right character.");
	assert(!c.match("d"), "Primitive matched the wrong character.");
	assert(!c.match("e"), "Primitive matched the wrong character.");
	assert(!c.match(""));
}

unittest // Union
{
	auto f = new Primitive('f');
	auto o = new Primitive('o');
	auto b = new Primitive('b');

	auto fo = new Union(f, o);
	auto ob = new Union(o, b);
	auto fob = new Union(f, ob);

	assert(fo.match("f"));
	assert(fo.match("o"));
	assert(!fo.match("b"));
	assert(!fo.match(""));

	assert(ob.match("o"));
	assert(ob.match("b"));
	assert(!ob.match("f"));
	assert(!ob.match(""));

	assert(fob.match("f"));
	assert(fob.match("o"));
	assert(fob.match("b"));
	assert(!fob.match("a"));
	assert(!fob.match(""));

	auto empty = new Empty();
	auto epsilon = new Epsilon();

	auto emptyEp = new Union(empty, epsilon);
	assert(emptyEp.match(""));
	assert(!emptyEp.match("f"));
	assert(!emptyEp.match("o"));
	assert(!emptyEp.match("b"));
	assert(emptyEp.nullable);

	auto emptyempty = new Union(empty, empty);
	assert(!emptyempty.match(""));
	assert(!emptyempty.match("c"));
	assert(!emptyempty.nullable);
}

unittest // Star
{
	auto c = new Primitive('c');
	auto cStar = new Star(c);


	assert(cStar.match(""));
	assert(cStar.match("c"));
	assert(cStar.match("cc"));
	assert(cStar.match("cccccccccccccccccccccccc"));
	assert(!cStar.match("acccccccccccc"));
	assert(!cStar.match("cccccccccccccca"));
	assert(!cStar.match("ccccccacccccccccc"));
}


unittest // Concat
{
	auto f = new Primitive('f');
	auto o = new Primitive('o');

	auto oo = new Concat(o, o);
	auto foo = new Concat(f, oo);

	assert(oo.match("oo"));
	assert(!oo.match(""));
	assert(!oo.match("foo"));

	assert(foo.match("foo"));
	assert(!foo.match(""));
	assert(!foo.match("foof"));
}

unittest // Complement
{
	auto f = new Primitive('f');
	auto o = new Primitive('o');

	auto oo = new Concat(o, o);
	auto foo = new Concat(f, oo);

	auto notFoo = new Complement(foo);
	assert(!notFoo.match("foo"));
	assert(notFoo.match("bar"));
	
}

unittest // Intersection
{
	auto f = new Primitive('f');
	auto o = new Primitive('o');
	auto b = new Primitive('b');
	auto a = new Primitive('a');
	auto r = new Primitive('r');
	auto z = new Primitive('z');

	auto foo = new Concat(f, new Concat(o, o));
	auto bar = new Concat(b, new Concat(a, r));
	auto baz = new Concat(b, new Concat(a, z));

	auto fooOrBar = new Union(foo, bar);
	auto barOrBaz = new Union(bar, baz);
	
  // (foo|bar)&(bar|baz)
	auto intersect = new Intersect(fooOrBar, barOrBaz);
	assert(intersect.match("bar"));
	assert(!intersect.match("foo"));
	assert(!intersect.match("baz"));
}

unittest // More interesting things
{

	auto f = new Primitive('f');
	auto o = new Primitive('o');

	// (foo)
	auto foo = new Concat(f, new Concat(o, o));
	assert(foo.match("foo"));
	assert(!foo.match("bar"));

	auto b = new Primitive('b');
	auto a = new Primitive('a');
	auto r = new Primitive('r');


	auto bar = new Concat(b, new Concat(a, r));
	assert(bar.match("bar"));
	assert(!bar.match("foo"));

	// (foo|bar)
	auto fooOrBar = new Union(foo, bar);
	assert(fooOrBar.match("foo"));
	assert(fooOrBar.match("bar"));
	assert(!fooOrBar.match("foobar"));

	// (foobar)
	auto foobar = new Concat(foo,bar);
	assert(foobar.match("foobar"));
	assert(!foobar.match("foo"));
	assert(!foobar.match("bar"));

	// (foo|bar)*
	auto fooOrBarStar = new Star(fooOrBar);
	assert(fooOrBarStar.match(""));
	assert(fooOrBarStar.match("foo"));
	assert(fooOrBarStar.match("bar"));
	assert(fooOrBarStar.match("foobar"));
	assert(fooOrBarStar.match("barfoo"));
	assert(fooOrBarStar.match("foofoofoofoofoofoobarbarbarfoofoofoo"));
	assert(!fooOrBarStar.match("fooNOTFOObar"));

	// (foo)*(bar)*
	auto fooStarBarStar = new Concat(new Star(foo), new Star(bar));
	assert(fooStarBarStar.match(""));
	assert(fooStarBarStar.match("foofoofoofoobarbarbarbar"));
	assert(!fooStarBarStar.match("foofoofoofoobarbarbarbarfoo"));
	assert(!fooStarBarStar.match("barfoofoofoofoofoobarbar"));
}























