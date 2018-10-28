#ifndef SIMPLE_H
#define SIMPLE_H

#include <Godot.hpp>

#include <Reference.hpp>
#include <vector>

#define NOMINMAX
#include "BLJPS/src/PathFindingAlgorithm.h"
//#include "BLJPS/src/Node.h"

using namespace godot;

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

	void setCell(int x, int y, bool blocked)
	{
		int index = y * width + x;
		// Turns a false to a true
		if(blocked)
		{
			gridData[index / 8] &= ~(1UL << (index % 8));
		}else {
			gridData[index / 8] |= (1 << index % 8);
		}

		// gridData[index / 8] |= (1 << index % 8);
		// gridData[index / 8] |= (1 << (index % 8));
		// gridData[index / 8] ^= (-bit ^ gridData[index / 8]) & (1 << (index % 8));
		// clearing 
		// number &= ~(1UL << n);

		// if (blocked)
		// {
		// 	gridData[index / 8] |= (1UL << (index % 8));
		// }
		//https://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit
		// gridData[index / 8] ^= (-bitValue ^ gridData[index / 8]) & (1UL <<(index % 8));

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

	MapGrid mapgrid;
	PathFindingAlgorithm *pathFindingAlgorithm;

  public:
	static void
	_register_methods();

	void _init();

	void init_map(int width, int height, PoolByteArray map_data);
	Array find_path(Vector2 from, Vector2 to, unsigned steps);
	bool check_tile(Vector2 tile_position);
	void updateTile(Vector2 tile_position, bool blocked);
};
#endif