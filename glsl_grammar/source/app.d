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
        "bool," : TestCaseInfo(["bool"], false),
        "int" : TestCaseInfo(["int"], false),
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

        
// Storage Qualifiers
unittest
{
    writeln("Running Storage Qualifier cases...");

    TestCaseInfo[string] cases = [
        "const" : TestCaseInfo(["const"], true),
        "inout" : TestCaseInfo(["inout"], true),
        "patch" : TestCaseInfo(["patch"], true),
        "subroutine" : TestCaseInfo(["subroutine"], true),
        "subroutine ( bob )" : TestCaseInfo(["subroutine", "(", "bob", ")"], true),
        "subroutine(int, float, sue)" : TestCaseInfo(["subroutine", "(", "int", ",", "float", ",", "sue", ")"], false),
        "subroutine(    )    " : TestCaseInfo(["subroutine", "(", ")"], false),
        ];

    foreach (testCase; cases.keys)
    {
        auto parseTree = GLSL.StorageQualifier(testCase);
        auto info = cases[testCase];

        assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
    }

}

// Layout Qualifiers
unittest
{
    writeln("Running Layout Qualifier cases...");

    TestCaseInfo[string] cases = [
        "layout(bob)" : TestCaseInfo(["layout", "(", "bob", ")"], true),
        "layout(location = 1)" : TestCaseInfo(["layout", "(", "location", "=", "1", ")"], true),
        "layout()" : TestCaseInfo(["layout", "(", ")"], false),
        "layout(a=1, b=2)" : TestCaseInfo(["layout", "(", "a", "=", "1", ",", "b", "=", "2", ")"], true),
        "layout (int)" : TestCaseInfo(["layout", "(", "int", ")"], false),
        "layout(a=1.2)" : TestCaseInfo(["layout", "(", "a", "=", "1.2", ")"], false),
        ];

    foreach (testCase; cases.keys)
    {
        auto parseTree = GLSL.LayoutQualifier(testCase);
        auto info = cases[testCase];

        assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
    }
}

// Function Call
unittest
{
    writeln("Running Function Call cases...");

    TestCaseInfo[string] cases = [
        "bob()" : TestCaseInfo(["bob", "(", ")"], true), 
        "bob(void)" : TestCaseInfo(["bob", "(", "void", ")"], true),       
        "bob(bob(), bob(void))" : TestCaseInfo(["bob", "(", "bob", "(", ")", ",", "bob", "(", "void", ")", ")"], true),
        "vec2(1.0, true)" : TestCaseInfo(["vec2", "(", "1.0", ",", "true", ")"], true),
        "vec2(1.0, true" : TestCaseInfo(["vec2", "(", "1.0", ",", "true"], false),
        "vec2 1.0, true)" : TestCaseInfo(["vec2", "1.0", ",", "true", ")"], false),
        "vec2 (1.0, true)" : TestCaseInfo(["vec2", "(", "1.0", ",", "true", ")"], true),
        ];

    foreach (testCase; cases.keys)
    {
        auto parseTree = GLSL.FunctionCall(testCase);
        auto info = cases[testCase];

        assert((parseTree.matches == info.tree) == info.expected, "Fail: " ~ testCase);
    }
}


void main()
{
    import std.string;
}

