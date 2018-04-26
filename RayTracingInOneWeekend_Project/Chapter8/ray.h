#ifndef RAYH
#define RAYH
#include "vec3.h"
class ray
{
public :
	ray(){}
	ray(const vec3& origin, const vec3& direction) { A = origin; B = direction; }
	vec3 origin() const { return A; }
	vec3 direction() const { return  B; }
	vec3 point_at_parameter(float t) const { return A + t*B; }

	vec3 A, B;
};

inline float drand48() { return  rand() % (100) / (float)(100); } // rand()%m 是产生一个0 -(m-1)的数;
vec3 random_in_unit_sphere()
{
	vec3 p;
	do
	{
		p = 2.0 * vec3(drand48(), drand48(), drand48()) - vec3(1, 1, 1);
	} while (p.squared_length() >= 1.0);
	return p;
}

#endif
