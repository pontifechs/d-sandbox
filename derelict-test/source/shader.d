module shader;
 
import std.file,
	std.regex,
	std.algorithm,
	std.conv,
	std.stdio;
import std.array;
import std.string : splitLines;
import derelict.opengl3.gl3;
 
class Shader
{
	GLuint vertShader,
			fragShader,
			geomShader,
			program;
	alias program this;
 
	this(string filename)
	{
		buildShaders(filename.readText());
	}
 
	void buildShaders(string src)
	{
		string[] directives;
		string[][string] parts;
 
		auto partMatch = regex(`^(\w+):`);
		string curType;
		foreach (line; src.splitLines())
		{
			if (line.startsWith("#"))
				directives ~= line;
 
			else {
				auto m = line.match(partMatch);
 
				if (m)
					curType = m.captures[1];
 
				else
					parts[curType] ~= line;
			}
		}
 
		// Get shader objects
		string source;
		if (auto s = "vertex" in parts)
		{
			vertShader = glCreateShader(GL_VERTEX_SHADER);
			source = (directives ~ *s).join("\n");
			const(char*) p = source.ptr;
			glShaderSource(vertShader, 1, &p, null);
			vertShader.compileShader();
		}
 
		if (auto s = "fragment" in parts)
		{
			fragShader = glCreateShader(GL_FRAGMENT_SHADER);
			source = (directives ~ *s).join("\n");
			const(char*) p = source.ptr;
			glShaderSource(fragShader, 1, &p, null);
			fragShader.compileShader();
		}
 
		//TODO geometry shader
 
		// Link into a program
		program = glCreateProgram();
		glAttachShader(program, vertShader);
		glAttachShader(program, fragShader);
		glLinkProgram(program);
 
		// Check the program
		int ret, logLen;
		glGetProgramiv(program, GL_LINK_STATUS, &ret);
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLen);
 
		if (logLen > 1)
		{
			char[] log = new char[](logLen);
			glGetProgramInfoLog(program, logLen, null, log.ptr);
			writeln("Program link log:\n", to!string(log));
		}
 
		glDeleteShader(vertShader);
		glDeleteShader(fragShader);
	}
 
	void bind()
	{
		glUseProgram(program);
	}
 
}
 
private void compileShader(GLuint shader)
{
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