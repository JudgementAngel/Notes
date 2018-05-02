#include <iostream>
#include <fstream>

using namespace std;

int main()
{
	int nx = 200,ny = 100;

	ofstream outfile("Result.ppm", ios_base::out);
	outfile << "P3\n" << nx << " " << ny << "\n255\n";

	cout << "P3\n" << nx << " " << ny << "\n255\n";
	for(int j = ny-1;j >= 0; j--)
	{
		for (int i = 0;i<nx;i++)
		{
			float r = float(i) / float(nx);
			float g = float(j) / float(ny);
			float b = 0.2f;

			int ir = int(255.99*r);
			int ig = int(255.99*g);
			int ib = int(255.99*b);

			outfile << ir << " " << ig << " " << ib << "\n";
			cout << ir << " " << ig << " " << ib << "\n";
		}
	}

	return 0;
}