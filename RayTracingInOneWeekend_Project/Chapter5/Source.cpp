#include <iostream>
#include <fstream>
#include "ray.h"

float hit_sphere(const vec3& center,float radius,const ray& r)
{
	vec3 oc = r.origin() - center;
	float a = dot(r.direction(), r.direction());
	float b = 2 * dot(oc, r.direction());
	float c = dot(oc, oc) - radius * radius;
	float discriminant = b * b - 4 * a * c;
	if (discriminant < 0)
	{
		return  -1.0f;
	}
	else
	{
		return (-b - sqrt(discriminant)) / (2.0f*a);
	}
}

vec3 color(const ray& r)
{
	float t = hit_sphere(vec3(0, 0, -1.0f), 0.5f, r);
	if (t > 0)
	{
		vec3 N = unit_vector(r.point_at_parameter(t) - vec3(0, 0, -1.0f));
		return 0.5 * vec3(N.x() + 1, N.y() + 1, N.z() + 1);
	}
	// Background Color
	vec3 unit_direction = unit_vector(r.direction());
	t = 0.5f * (unit_direction.y() + 1.0f);
	return (1.0f - t)*vec3(1.0f, 1.0f, 1.0f) + t*vec3(0.5f, 0.7f, 1.0f);
}

int main(int argc, char* argv[])
{
	int nx = 200;
	int ny = 100;

	std::ofstream outfile("Result.ppm", std::ios_base::out);
	outfile << "P3\n" << nx << " " << ny << "\n255\n";

	std::cout << "P3\n" << nx << " " << ny << "\n255\n";

	vec3 lower_left_corner(-2.0f, -1.0f, -1.0f);
	vec3 horizontal(4.0f,0.0f,0.0f);
	vec3 vertical(0.0f, 2.0f, 0.0f);
	vec3 origin(0.0f, 0.0f, 0.0f);
	for(int j = ny-1;j>=0;--j)
	{
		for (int i = 0;i<nx;++i)
		{
			float u = float(i) / float(nx);
			float v = float(j) / float(ny);
			ray r(origin, lower_left_corner + u*horizontal + v*vertical);
			vec3 col = color(r);
			
			int ir = int(255.99 * col[0]);
			int ig = int(255.99 * col[1]);
			int ib = int(255.99 * col[2]);

			outfile << ir << " " << ig << " " << ib << "\n";
			std::cout << ir << " " << ig << " " << ib << "\n";
		}
	}
}
