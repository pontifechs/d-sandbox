module deagle.util.General;

import std.functional;

alias unaryFun!("(a & 1) == 0") isEven;

string ChangeAware(alias typesNames)()
{
	static assert(is(typeof(typesNames) == string[]));
	static assert(typesNames.length.isEven);

	string ret = "private bool hasChanged_ = false;\n";

	ret ~= "public bool hasChanged() @property { ";
	ret ~= "bool changed = hasChanged_; hasChanged_ = false; return changed; }\n";
	ret ~= "@property {\n";
	
	for (auto i = 0; i < typesNames.length; i+= 2)
	{
		auto type = typesNames[i];
		auto name = typesNames[i+1];

		ret ~= "private " ~ type ~ " " ~ name ~ "_;\n";
		ret ~= type ~ " " ~ name ~ "() { return " ~ name ~ "_; }\n";
		ret ~= type ~ " " ~ name ~ "(" ~ type ~ " " ~ name ~ ") {";
		ret ~= "hasChanged_ = true; return " ~ name ~ "_ = " ~ name ~ "; }\n";
	}
	
	ret ~= "}\n";

	return ret;
}


unittest 
{
	struct CA
	{
		mixin(ChangeAware!(["int", "foo", "float", "bar"]));
	}

	auto ca = CA();

	// Check that accessing members that should be there succeeds
	assert(__traits(compiles, ca.foo));
	assert(__traits(compiles, ca.foo = 5));
	assert(__traits(compiles, ca.bar));
	assert(__traits(compiles, ca.bar = 2.36));

	// Check hasChanged;
	assert(!ca.hasChanged);
	ca.foo = 5;
	assert(ca.hasChanged);

	// Checking if it's changed after check already should not return true;
	assert(!ca.hasChanged);
}
