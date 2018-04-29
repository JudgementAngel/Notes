#ifndef RAYH
#define RAYH
#include "vec3.h"
#define M_PI 3.1415926f

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


#endif
