import std.stdio;

struct Foo
{
public:
	int i;
	int j;

	this(int i)(int j, int k)
	{
		this.i = i + j;
		this.j = i + k;
	}

	// static notOpCall(int i)(int j, int k)
	// {
	// 	return Foo(i+j,i+k);
	// }
}

void main()
{	
	auto bob = Foo!(1)(2,3); //Error: template instance Foo!1 Foo is not a template declaration, it is a struct
}


