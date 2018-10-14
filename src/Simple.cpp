#include "Simple.hpp"
#include "JPS.h"

using namespace godot;

void Simple::_register_methods()
{
	register_method("init_map", &Simple::init_map);
	register_method("find_path", &Simple::find_path);
}

void Simple::_init()
{
}


void Simple::init_map(int width, int height, PoolByteArray map_data)
{
	mygrid = MyGrid(width, height, map_data);
}

Array Simple::find_path(Vector2 from, Vector2 to, unsigned steps)
{
	JPS::PathVector path;
	bool found = JPS::findPath(path, mygrid, from.x, from.y, to.x, to.y, steps);
	PoolVector2Array return_path = PoolVector2Array();
	
	for(auto&& pos : path)
	{
		return_path.append(Vector2(pos.x, pos.y));
	}
	return return_path;
}