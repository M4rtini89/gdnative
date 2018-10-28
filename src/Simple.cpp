#include "Simple.hpp"
#include "BLJPS/src/Astar.h"
#include "BLJPS/src/JPS.h"
#include "BLJPS/src/BL_JPS.h"
#include "BLJPS/src/JPS_Plus.h"
using namespace godot;

void Simple::_register_methods()
{
	register_method("init_map", &Simple::init_map);
	register_method("find_path", &Simple::find_path);
	register_method("check_tile", &Simple::check_tile);
	register_method("updateTile", &Simple::updateTile);
}

void Simple::_init()
{
}

void Simple::init_map(int width, int height, PoolByteArray map_data)
{
	mapgrid = MapGrid();
	mapgrid.fillGrid(width, height, map_data);
	// pathFindingAlgorithm = new BL_JPS(mapgrid.gridData, width, height);
	pathFindingAlgorithm = new JPS(mapgrid.gridData, width, height);
	pathFindingAlgorithm->preProcessGrid();
}

Array Simple::find_path(Vector2 from, Vector2 to, unsigned steps)
{
	PoolVector2Array return_path = PoolVector2Array();
	// JPS::PathVector path;
	// bool found = JPS::findPath(path, mygrid, from.x, from.y, to.x, to.y, steps);
	// // bool found = JPS::findPath(path, mapgrid, from.x, from.y, to.x, to.y, steps);

	// for (auto &&pos : path)
	// {
	// 	return_path.append(Vector2(pos.x, pos.y));
	// }

	vector<Coordinate> solution;
	pathFindingAlgorithm->findSolution(to.x, to.y, from.x, from.y, solution);
	for (auto &&pos : solution)
	{
		return_path.append(Vector2(pos.x, pos.y));
	}

	return return_path;
}

bool Simple::check_tile(Vector2 tile_position)
{
	return mapgrid(tile_position.x, tile_position.y);
}

void Simple::updateTile(Vector2 tile_position, bool blocked)
{
	mapgrid.setCell(tile_position.x, tile_position.y, blocked);
}