module regexParser;

import std.stdio;

import regexDerivatives;


// Parsing string to regex tree
struct RegexParser
{
private:
	string pattern;
	int index;

	// Return the current character
	char peek()
	{
		return pattern[index];
	}

	// Removes the given character if it's the next letter.
	void eat(char c)
	{
		if (peek() == c)
		{
			index++;
		}
		else
		{
			throw new Exception("Expected: " ~ c ~ "; got: " ~ peek()) ;
		}
	}

	// eat and return (pop)
	char next()
	{
		char c = peek();
		eat(c);
		return c;
	}

	// See if we're done.
	bool more() {
    return index < pattern.length;
  }	

// <regex>  ::= <term> { <termop> <term> }
// <termop> ::= '|' | '&'
// <term>   ::= { <factor> }
// <factor> ::= <base> { '*' }
// <base>   ::= [ '~' ] <atom>
// <atom>   ::= '\' <char>
//           |  <char>
//           |  '(' <regex> ')'

	// Production rules ----------------
	Regex regex() 
	{
		// Have to get at least one <term>, then 0 or more <termop><term> s.
		Regex term = term();
		
		// Continue grabbing ops and terms until we run out or hit something.
		while(more() && (peek() == '|' || peek() == '&'))
		{
			char next = peek();
			// Pull the op off.
			eat(next);
			// Grab the next term.
			Regex nextTerm = this.term();
			// Build the appropriate Regex Subtype based on the op.
			switch(next)
			{
			case '|':
				term = new Union(term, nextTerm);
				break;
			case '&':
				term = new Intersect(term, nextTerm);
				break;
			default:
				throw new Exception("Got " ~ next ~ ". Should've only gotten | or &.");
			}
		}
		return term;
	}


	Regex term()
	{
		// Grab the first factor 
		Regex factor = factor();

		// keep going until we hit something
		while(more() && peek() != '|' && peek() != '&' && peek() != ')')
		{
			Regex nextFactor = this.factor();
			factor = new Concat(factor, nextFactor);
		}
		return factor;
	}

	Regex factor()
	{
		// Pull a base
		Regex base = base();
		
		// Grab any stars after it.
		while (more() && peek() == '*')
		{
			eat('*');
			// wrap in a kleene star (all but the first is redundant, but whatever.
			base = new Star(base);
		}
		return base;
	}

	Regex base()
	{
		// Check for a complement.

		auto complements = 0;
		while(more() && peek() == '~')
		{
			eat('~');
			complements++;
		}
		// if we have an odd number of complements, we need to complement.
		bool shouldComplement = (complements % 2 == 1);

		// Grab one atom.
		Regex atom = atom();

		// Complement it if necessary
		if (shouldComplement)
		{
			atom = new Complement(atom);
		}
		return atom;
	}

	Regex atom()
	{
		char next = peek();
		switch (next)
		{
		// Escaped character, just grab the next character verbatim.
		case '\\':
			// Eat the backslash, and primitive the next character.
			eat('\\');
			return new Primitive(this.next());

			// Starting another regex
		case '(':
			eat('(');
			Regex ret = regex();

			if (this.next() != ')')
			{
				throw new Exception("Missing empty paren");
			}
			return ret;


			// Sanity checks on the special chars. (They should never get here I think.)
		case '|':
			throw new Exception("Got a non-escaped | as a primtive.");
		case '&':
			throw new Exception("Got a non-escaped & as a primitive.");
		case '~':
			throw new Exception("Got a non-escaped ~ as a primitive.");
		case '*':
			throw new Exception("Got a non-escaped * as a primitive.");			

			// Treat the character as is.
		default:
			return new Primitive(this.next());
		}
	}


public:
	this(string pattern)
	{
		this.pattern = pattern;
		this.index = 0;
	}

	Regex parse()
	{
		return this.regex();
	}
}



void main()
{
}


unittest // peek, eat, next
{
	auto parser = RegexParser("foobar");

	assert(parser.pattern == "foobar");
	assert(parser.index == 0);
	assert(parser.peek() == 'f');

	parser.eat('f');

	assert(parser.pattern == "foobar");	
	assert(parser.index == 1);
	assert(parser.peek() == 'o');

	assert(parser.next() == 'o');

	assert(parser.pattern == "foobar");	
	assert(parser.index == 2);
	assert(parser.peek() == 'o');
	
	import std.exception;
	assertThrown(parser.eat('a'));


}

unittest // Single Primitive
{
	auto parser = RegexParser("f");
	auto f = parser.parse();

	assert(f.match("f"));
	assert(!f.match(""));
	assert(!f.match("a"));
}

unittest // More primitives
{
	auto foParser = RegexParser("fo");
	auto fo = foParser.parse();

	assert(fo.match("fo"));
	assert(!fo.match("foo"));
	assert(!fo.match(""));

	auto fooParser = RegexParser("foo");
	auto foo = fooParser.parse();

	assert(foo.match("foo"));
	assert(!foo.match("fooo"));
	assert(!foo.match(""));

	auto slashParser = RegexParser("\\\\");
	auto slash = slashParser.parse();
	
	assert(slash.match("\\"));

}

unittest // Union
{

	auto fooOrBar = RegexParser("foo|bar").parse();
	
	assert(fooOrBar.match("foo"));
	assert(fooOrBar.match("bar"));
	assert(!fooOrBar.match("baz"));
	assert(!fooOrBar.match(""));
	
}


unittest // Parens
{
	auto parenPrim = RegexParser("(f)").parse();
	assert(parenPrim.match("f"));
	assert(!parenPrim.match("a"));

	auto multiParenPrim = RegexParser("((f))").parse();
	assert(multiParenPrim.match("f"));
	assert(!multiParenPrim.match("a"));

	auto obfFoo = RegexParser("(f)(((o))(o))").parse();
	assert(obfFoo.match("foo"));
	assert(!obfFoo.match("bar"));
}

unittest // Star
{
	auto fooStar = RegexParser("(foo)*****").parse();
	assert(fooStar.match("foo"));
	assert(fooStar.match(""));
	assert(fooStar.match("foofoo"));
	assert(fooStar.match("foofoofoofoofoofoofoofoofoo"));
	assert(!fooStar.match("bar"));
	assert(!fooStar.match("foofoofoofoofoofoofoofoofoobar"));
}

unittest // Intersection
{
	auto bar = RegexParser("(foo|bar)&(bar|baz)").parse();
	assert(bar.match("bar"));
	assert(!bar.match("foo"));
	assert(!bar.match("baz"));
	assert(!bar.match(""));
}


unittest // Complement
{
	auto notFoo = RegexParser("~(foo)").parse();
	assert(notFoo.match("bar"));
	assert(notFoo.match("baz"));
	assert(notFoo.match(""));
	assert(!notFoo.match("foo"));

	auto foo = RegexParser("~~(foo)").parse();
	assert(foo.match("foo"));
	assert(!foo.match(""));
	assert(!foo.match("bar"));
}

unittest // Given tests
{
	auto evenAndDivByFive = RegexParser("((0|1|2|3|4|5|6|7|8|9)*(0|2|4|6|8))&((0|1|2|3|4|5|6|7|8|9)*(0|5))").parse();
	
	assert(evenAndDivByFive.match("20"));
	assert(evenAndDivByFive.match("30"));
	assert(!evenAndDivByFive.match("35"));

	auto foo = RegexParser("ab~((b|a|0|1)*ba(b|a|0|1)*)ba").parse();
	assert(foo.match("ab00101001ba"));
	assert(!foo.match("abbaba"));
}
