module deagle.graphics.Shader;



import deagle.graphics.GL;
import pegged.grammar;



enum UniformGrammar = `


Types



`;



string buildUniforms(string source)
{
	import std.stdio;
	import std.string;
	import std.regex;
	import std.algorithm;

	auto r = regex(`.*uniform.*`);

	auto uniformLines = 
		source
		.splitLines
		.filter!(s => match(s, r))
		.join
		.split(";")
		.filter!(s => match(s, r));
	
	//writeln(uniformLines);
	
	return source;
}



unittest
{

	auto test = `

struct bob
{
}


function dostuff()
{
return uniformThing;
}

asdf
asdf

asdfas
dfasdfasdf

uniform vec2 bob;

uniformvec2notbob;

one two three; uniform vec3 bob; 
uniform mat4 asdf23423;

""
"



`;

	
	buildUniforms(test);


}
