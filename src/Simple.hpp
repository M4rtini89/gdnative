#include <Godot.hpp>

#include <Reference.hpp>
#include <vector>

using namespace godot;

typedef std::vector<bool> bool_vec_t;

struct MyGrid
{
	bool_vec_t data;
	unsigned width, height;

	MyGrid()
	{

	}

	MyGrid(unsigned _width, unsigned _height, PoolByteArray map_data)
	{
		width = _width;
		height = _height;
		data.resize(width * height);
		init_map(map_data);
	}
private:
	void init_map(PoolByteArray map_data)
	{
		int elements = width * height;
		if (elements == map_data.size())
		{
			for(size_t i = 0; i < elements; i++)
			{
				data[i] = map_data[i];
			}
		}
	}
public:
	inline bool operator()(unsigned x, unsigned y) const
	{
		if(x < width && y < height)
		{
			return data[x + width * y] == 1;
		} else {
			return false;
		}
	}
};

class Simple : public GodotScript<Reference> {
	GODOT_CLASS(Simple)
	
	MyGrid mygrid;

public:

	static void _register_methods();

	void _init();

	void init_map(int width, int height, PoolByteArray map_data);
	Array find_path(Vector2 from, Vector2 to, unsigned steps);
};
