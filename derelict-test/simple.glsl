#version 330
 
vertex:
layout(location=0) in vec3 position;
 
//uniform mat4 projection;
//uniform mat4 view;
//uniform mat4 model;
 
void main()
{
	//gl_Position = projection * view * model * vec4(position, 0);
	gl_Position = vec4(position, 1);
}
 
fragment:
out vec3 color;
void main()
{
	color = vec3(0.5, 0.0, 0.0);
}
