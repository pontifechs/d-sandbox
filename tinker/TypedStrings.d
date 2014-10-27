
import std.stdio;
import std.regex;
import std.typecons;



struct TypedString(string pattern)
{
private:    
    string val;

    static auto regex = ctRegex!(pattern);

public:    
    mixin Proxy!val;

    this(string s)
    {
        val = s;
        writeln(matchFirst(val, regex));
    }

    invariant()
    {
        assert(!matchFirst(val, regex).empty, "String " ~ val ~ " does not match pattern " ~ pattern); 
    }

}

alias AllA = TypedString!("a*");
alias Bob = TypedString!("(bob)*");

void main()
{
    Bob bob = "bob"; 
    AllA a = "aaaaaaaaa";

}


