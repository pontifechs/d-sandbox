module deagle.graphics.Shader;

import std.stdio;
import std.typecons;
import pegged.grammar;


mixin("enum GLSL_WIP = `" ~ import("GLSL_WIP.peg") ~ "`;");
mixin(grammar(GLSL_WIP));


alias Tuple!(string[], "tree", bool, "expected") TestCaseInfo;



// identifier
unittest
{
	writeln("Running Identifier cases...");

	TestCaseInfo[string] cases = [ 
		"bool " : TestCaseInfo(["bool"], false),
		"boolVar" : TestCaseInfo(["boolVar"], true),
		"vec2bool" : TestCaseInfo(["vec2bool"], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Identifier(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Floats
unittest
{
	writeln("Running Float cases...");

	TestCaseInfo[string] cases = [ 
		"3.14" : TestCaseInfo(["3.14"], true),
		"0.0.2" : TestCaseInfo(["0.0.2"], false),
		".32" : TestCaseInfo([".32"], true),
		"3.14f" : TestCaseInfo(["3.14f"], true),
		"3.14F" : TestCaseInfo(["3.14F"], true),
		"4e2" : TestCaseInfo(["4e2"], true),
		"4.20e203" : TestCaseInfo(["4.20e203"], true),
		"3e-2" : TestCaseInfo(["3e-2"], true),
		"0.2" : TestCaseInfo(["0.2"], true),
		"0.2 " : TestCaseInfo(["0.2"], true),
		" 0.2" : TestCaseInfo(["0.2"], false),
		"23" : TestCaseInfo(["23"], false),
		"2e" : TestCaseInfo(["2e"], false),
		];

	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.FloatingLiteral(testCase);
		auto info = cases[testCase];
		
		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Integers
unittest
{
	writeln("Running Integer cases...");

	TestCaseInfo[string] cases = [ 
		"4" : TestCaseInfo(["4"], true),
		"0030" : TestCaseInfo(["0030"], true),
		"1" : TestCaseInfo(["1"], true),

		"0x1353afd" : TestCaseInfo(["0x1353afd"], true),
		"0X1353afd" : TestCaseInfo(["0X1353afd"], true),
		"0X1245Q" : TestCaseInfo(["0X1245Q"], false),

		"0123357" : TestCaseInfo(["0123357"], true),

		"4u" : TestCaseInfo(["4u"], true),

		"0x3512fadU" : TestCaseInfo(["0x3512fadU"], true),

		"|" : TestCaseInfo(["|"], false),
		"a" : TestCaseInfo(["a"], false),
		"||" : TestCaseInfo(["||"], false),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.IntegerLiteral(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}


// BoolLiteral
unittest
{
	writeln("Running Bool cases...");

	TestCaseInfo[string] cases = [ 
		"true" : TestCaseInfo(["true"], true),
		"false" : TestCaseInfo(["false"], true),
		" bob" : TestCaseInfo(["bob"], false),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.BooleanLiteral(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Postfix
unittest
{
	writeln("Running Postfix cases...");

	TestCaseInfo[string] cases = [ 
		"1++" : TestCaseInfo(["1", "++"], true),
		"1.0--" : TestCaseInfo(["1.0", "--"], true),
		"arr[1]" : TestCaseInfo(["arr", "[", "1", "]"], true),
		"arr[one()]" : TestCaseInfo(["arr", "[", "one", "(", ")", "]"], true),
		"asdf.bob" : TestCaseInfo(["asdf", ".", "bob"], true),
		"vec.bob" : TestCaseInfo(["vec", ".", "bob"], true),
		"bob()" : TestCaseInfo(["bob", "(", ")"], true),
		"thing().bob" : TestCaseInfo(["thing", "(", ")", ".", "bob"], true),
		"arr[1].bob" : TestCaseInfo(["arr", "[", "1", "]", ".", "bob"], true),
		];

	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Postfix(testCase);
		auto info = cases[testCase];
 
		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Prefix
unittest
{
	writeln("Running Prefix cases...");

	TestCaseInfo[string] cases = [ 
		"!true" : TestCaseInfo(["!", "true"], true),
		"-arr[0]" : TestCaseInfo(["-", "arr", "[", "0", "]"], true),
		"!one(arr[1.0]))" : TestCaseInfo(["!", "one", "(", "arr", "[", "1.0", "]", ")"], true),
		"(true)" : TestCaseInfo(["(", "true", ")"], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Prefix(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Multiplicative
unittest
{
	writeln("Running Multiplicative cases...");

	TestCaseInfo[string] cases = [ 
		"1.0 * 4e2" : TestCaseInfo(["1.0", "*", "4e2"], true),
		"arr[0] % bob()" : TestCaseInfo(["arr", "[", "0", "]", "%", "bob", "(", ")"], true),
		"1 * 2 / 3 % 4" : TestCaseInfo(["1", "*", "2", "/", "3", "%", "4"], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Multiplicative(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Additive
unittest
{
	writeln("Running Additive cases...");

	TestCaseInfo[string] cases = [ 
		"1+2" : TestCaseInfo(["1", "+", "2"], true),
		"1 +2 / 3" : TestCaseInfo(["1", "+", "2", "/", "3"] , true),
		"1 - (arr[5])" : TestCaseInfo(["1", "-", "(", "arr", "[", "5", "]", ")"], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Additive(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Shift
unittest
{
	writeln("Running Shift cases...");

	TestCaseInfo[string] cases = [ 
		"1 << 2" : TestCaseInfo(["1", "<<", "2"], true),
		"bob() >> 2 - 3" : TestCaseInfo(["bob", "(", ")", ">>", "2", "-", "3"], true),
		"3 + - veec().bob" : TestCaseInfo(["3", "+", "-", "veec", "(", ")", ".", "bob"], true),
		];

	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Shift(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Relational Expression
unittest
{
	writeln("Running Relational cases...");

	TestCaseInfo[string] cases = [ 
		"a > b" : TestCaseInfo(["a", ">", "b"], true),
		"vec2() <= bool(1,2)" : TestCaseInfo(["vec2", "(", ")", "<=", "bool", "(", "1", ",", "2", ")"], true),
		" 1 < 2 > 3" : TestCaseInfo(["1", "<", "2", ">", "3"], false),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Relational(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}


// Equality
unittest
{
	writeln("Running Equality cases...");

	TestCaseInfo[string] cases = [ 
		"1 << 2 == 3" : TestCaseInfo(["1", "<<", "2", "==", "3"], true),
		"+2 * vec2() != thing.bob" : TestCaseInfo(["+", "2", "*", "vec2", 
																							 "(", ")", "!=", "thing", 
																							 ".", "bob"], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Equality(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Bitwise Ops
unittest
{
	writeln("Running BitwiseOps cases...");

	TestCaseInfo[string] cases = [ 
		"1 & 2 | 3 ^ 4" : TestCaseInfo(["1", "&", "2", "|", "3", "^", "4"], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.BitwiseOr(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Logical Ops
unittest
{
	writeln("Running LogicalOps cases...");

	TestCaseInfo[string] cases = [ 
		"bob || sue && tim ^^ b" : TestCaseInfo(["bob", "||", "sue", "&&", "tim", "^^", "b"], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.LogicalOr(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}


// Selection
unittest
{
	writeln("Running Selection cases...");

	TestCaseInfo[string] cases = [ 
		"bob ? a : b" : TestCaseInfo(["bob", "?", "a", ":", "b"], true),
		"3 ? 1 + 2 : vec2().x" : TestCaseInfo(["3", "?", "1", "+", "2", ":", 
																					 "vec2", "(", ")", ".", "x" ], true),
		];


	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Selection(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}


// AssignmentOps
unittest
{
	writeln("Running AssignmentOps cases...");

	TestCaseInfo[string] cases = [ 
		"bob = 1 + 2" : TestCaseInfo(["bob", "=", "1", "+", "2"], true),
		"one &= 2" : TestCaseInfo(["one", "&=", "2"], true),
		"it <<= a ? b : vec3()" : TestCaseInfo(["it", "<<=", "a", "?", "b", ":", 
																						"vec3", "(", ")"], true),
		"bob = {1}" : TestCaseInfo(["bob", "=", "{", "1", "}"], true),
		"true || false = {1}" : TestCaseInfo(["true", "||", "false", "=", "{", "1", "}"], true),

		];

	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.AssignmentOps(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}

// Intializer
unittest
{
	writeln("Running Initializer cases...");

	TestCaseInfo[string] cases = [ 
		"{ 1, 2+3, 4=5, bob}" : TestCaseInfo(["{", "1", ",", "2", "+", "3", 
																					",", "4", "=", "5", ",", "bob", "}"], true),
		"{ { 1, 0}, { bob} }" : TestCaseInfo(["{", "{", "1", ",", "0", "}", ",", "{", 
																					"bob", "}", "}"], true),
		];

	foreach (testCase; cases.keys)
	{
		auto parseTree = GLSL.Initializer(testCase);
		auto info = cases[testCase];

		assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
	}
}



void main()
{
	import derelict.opengl3.gl3;
	import derelict.glfw3.glfw3;

	import std.string;

	DerelictGL3.load();
	DerelictGLFW3.load();


	if (!glfwInit())
	{
		writeln("couldn't load glfw");
	}
	scope(exit) glfwTerminate();


	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
	auto window = glfwCreateWindow(800, 600, "Thing", null, null);
	assert(window !is null);
	glfwMakeContextCurrent(window);
 
	auto vers = DerelictGL3.reload();


  // Pass in the source
  const auto source = "
#version 410
 

layout(location=0) in vec3 position;
 
//uniform mat4 projection;
//uniform mat4 view;
//uniform mat4 model;
 
void main()
{
	//gl_Position = projection * view * model * vec4(position, 0);
	gl_Position = vec4(position, 1);
}
 
";
	

	GLuint shader = glCreateShader(GL_VERTEX_SHADER);
	const(char*) p = source.ptr;
	glShaderSource(shader, 1, &p, null);

	
	glCompileShader(shader);
 
	// Check Vertex Shader
	int ret, logLen;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &ret);
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLen);
 
	if (logLen > 1)
	{
		char[] log = new char[](logLen);
		glGetShaderInfoLog(shader, logLen, null, log.ptr);
		writeln("Shader compile log:\n", to!string(log));
	}
	

}

