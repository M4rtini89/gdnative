#ifndef SIMPLE_H
#define SIMPLE_H

#include <Godot.hpp>

#include <Reference.hpp>
#include <vector>

#define NOMINMAX
#include "BLJPS/src/PathFindingAlgorithm.h"
//#include "BLJPS/src/Node.h"

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
			for (size_t i = 0; i < elements; i++)
			{
				data[i] = map_data[i];
			}
		}
	}

  public:
	inline bool operator()(unsigned x, unsigned y) const
	{
		if (x < width && y < height)
		{
			return data[x + width * y] == 1;
		}
		else
		{
			return false;
		}
	}
};

struct MapGrid
{
	MapGrid()
	{
		gridData = 0;
		width = 0;
		height = 0;
	}

	~MapGrid()
	{
		cleanUp();
	}

	bool fillGrid(int _width, int _height, PoolByteArray data)
	{
		if (gridData)
		{
			cleanUp();
		}
		height = _height;
		width = _width;
		sizeBytes = width * height / 8 + 1;
		gridData = new char[sizeBytes];

		memset(gridData, 0, sizeBytes);
		for (int y = 0; y < height; y += 1)
		{
			for (int x = 0; x < width; x += 1)
			{
				int index = y * width + x;
				int val = data[index];
				// Val == 0 mean a blocked cell.
				if (val == 0)
				{
					gridData[index / 8] |= (1 << index % 8);
					if (index / 8 > sizeBytes - 1)
						printf("MapGridData: Error buffer overflow\n");
				}
			}
		}

		return true;
	}

	void cleanUp()
	{
		if (gridData)
		{
			delete[] gridData;
			gridData = 0;
			width = 0;
			height = 0;
		}
	}

	inline bool operator()(unsigned x, unsigned y) const
	{
		if (x < width && y < height)
		{
			int index = x + width * y;
			return !(gridData[index / 8] & (1 << (index % 8)));
		}
		else
		{
			return false;
		}
	}

	char *gridData;
	int sizeBytes;
	int width, height;
};
class Simple : public GodotScript<Reference>
{
	GODOT_CLASS(Simple)

	MyGrid mygrid;
	MapGrid mapgrid;
	PathFindingAlgorithm *pathFindingAlgorithm;

  public:
	static void
	_register_methods();

	void _init();

	void init_map(int width, int height, PoolByteArray map_data);
	Array find_path(Vector2 from, Vector2 to, unsigned steps);
	bool check_tile(Vector2 tile_position);
};
#endif