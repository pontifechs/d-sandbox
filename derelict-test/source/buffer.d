module buffer;
 
import derelict.opengl3.gl3;
 
class VertexArray
{
	GLuint vao;
	alias vao this;
 
	this()
	{
		glGenVertexArrays(1, &vao);
	}
 
	void bind()
	{
		glBindVertexArray(vao);
	}
 
	void bind(GLuint loc, GLenum type, int components, int stride, int offset = 0, bool normalize = false)
	{
		bind();
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, components, type, 
								normalize, stride, cast(void*)offset);
	}
}
 
class Buffer
{
	GLuint buffer;
	alias buffer this;
 
	this(T)(T[] data)
	{
		glGenBuffers(1, &buffer);
		setData(data);
	}
 
	void bind()
	{
		glBindBuffer(GL_ARRAY_BUFFER, buffer);
	}
 
 
	void setData(T)(T[] data)
	{
		bind();
		glBufferData(GL_ARRAY_BUFFER, 
					 T.sizeof * data.length, 
					 data.ptr, GL_STATIC_DRAW);
	}
 
}