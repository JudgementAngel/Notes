#include <iostream>
#include <fstream>
#include "sphere.h"
#include "hitable_list.h"
#include "camera.h"
#include "lambertian.h"
#include "metal.h"

#define MAXFLOAT std::numeric_limits<float>::max()

vec3 color(const ray& r, hitable *world,int depth)
{
	hit_record rec;
	if (world->hit(r, 0.001f, MAXFLOAT, rec))
	{
		ray scattered;
		vec3 attenuation;
		if(depth<50 && rec.mat_ptr->scatter(r,rec,attenuation,scattered))
		{
			return attenuation * color(scattered, world, depth + 1);
		}
		else { return vec3(0, 0, 0); }
	}
	else
	{
		// Background Color
		vec3 unit_direction = unit_vector(r.direction());
		float t = 0.5f * (unit_direction.y() + 1.0f);
		return (1.0f - t)*vec3(1.0f, 1.0f, 1.0f) + t*vec3(0.5f, 0.7f, 1.0f);
	}
}



int main()
{
	int nx = 200;
	int ny = 100;
	int ns = 100;

	std::ofstream outfile("Result.ppm", std::ios_base::out);

	outfile << "P3\n" << nx << " " << ny << "\n255\n";
	std::cout << "P3\n" << nx << " " << ny << "\n255\n";

	hitable *list[4];
	list[0] = new sphere(vec3(0, 0, -1), 0.5,new lambertion(vec3(0.8f,0.3f,0.3f)));
	list[1] = new sphere(vec3(0, -100.5, -1), 100,new lambertion(vec3(0.8f, 0.3f, 0.0)));
	list[2] = new sphere(vec3(1,0,-1), 0.5, new metal(vec3(0.8f, 0.6f, 0.2f),10.5f));
	list[3] = new sphere(vec3(-1, 0, -1), 0.5, new metal(vec3(0.8f, 0.8f, 0.8f),0));
	hitable *world = new hitable_list(list, 4);

	camera cam;

	for (int j = ny - 1; j >= 0; --j)
	{
		for (int i = 0; i < nx; ++i)
		{
			vec3 col(0, 0, 0);
			for (int s = 0; s < ns; ++s)
			{
				float random = drand48();
					float u = float(i + random) / float(nx);
				float v = float(j + random) / float(ny);

				ray r = cam.get_ray(u, v);
				vec3 p = r.point_at_parameter(2.0);
				col += color(r, world,0);
			}
			col /= float(ns);

			col = vec3(sqrt(col[0]), sqrt(col[1]), sqrt(col[2]));

			int ir = int(255.99 * col[0]);
			int ig = int(255.99 * col[1]);
			int ib = int(255.99 * col[2]);

			outfile << ir << " " << ig << " " << ib << "\n";
			std::cout << ir << " " << ig << " " << ib << "\n";
		}
	}
}
