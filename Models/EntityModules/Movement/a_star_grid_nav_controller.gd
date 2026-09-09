class_name AStarGridNavController extends Node2D

const IS_SOLID_DATA_LAYER = "is_solid";
const MOVE_TOLERANCE := 0.5;

@export var movement_controller: MovementController;

var astargrid: AStarGrid2D = AStarGrid2D.new();
var tile_map_layer: TileMapLayer;

var current_tile_pos: Vector2i;
var target_tile_pos: Vector2i;
var next_path_tile: Vector2i;
var nav_path: Array[Vector2i];

func _ready() -> void:
	Blackboard.blackboard_updated.connect(_connect_map);

func _process(delta: float) -> void:
	queue_redraw();

func _connect_map() -> void:
	var map := Blackboard.get_map();
	if (map):
		map.on_map_generated.connect(_update_tile_map);
		_update_tile_map();

func _setup_grid() -> void:
	# TODO: This should be parameterized from the map
	astargrid.region = Rect2(0, 0, 31, 31);
	astargrid.cell_size = tile_map_layer.tile_set.tile_size;
	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN;
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER;
	astargrid.update();

	for cell in tile_map_layer.get_used_cells():
		astargrid.set_point_solid(cell, _is_cell_solid(cell));

func _update_tile_map() -> void:
	tile_map_layer = Blackboard.get_map().tile_map_layer;
	_setup_grid();

func _is_cell_solid(cell_pos: Vector2i) -> bool:
	if (!tile_map_layer.get_cell_tile_data(cell_pos)): return false;

	var result: bool = tile_map_layer.get_cell_tile_data(cell_pos).get_custom_data(IS_SOLID_DATA_LAYER);
	return result;

func _calculate_nav_path(start_pos: Vector2i, end_pos: Vector2i) -> Array[Vector2i]:
	return astargrid.get_id_path(start_pos, end_pos);

func set_nav_target(p_target_tile_pos: Vector2i) -> void:
	target_tile_pos = p_target_tile_pos;

func _calculate_next_nav_path() -> void:
	if (!target_tile_pos): return;
	var map := Blackboard.get_map();

	current_tile_pos = map.get_tile_from_position(movement_controller.moveable_character.global_position);
	nav_path = _calculate_nav_path(current_tile_pos, target_tile_pos);
	
	if (nav_path.size() == 0): return;
	next_path_tile = nav_path[0];

func move_next_in_path(delta: float) -> void:
	if (!next_path_tile || _has_reached_path()):
		_calculate_next_nav_path();

		if (next_path_tile == current_tile_pos && nav_path.size() > 1):
			next_path_tile = nav_path[1];
		
	if (next_path_tile):
		var map := Blackboard.get_map();
		var nav_delta := movement_controller.moveable_character.global_position - map.get_position_from_tile(next_path_tile);
		
		if (nav_delta.y > MOVE_TOLERANCE):
			movement_controller.move_up(delta)
		elif (nav_delta.y < -MOVE_TOLERANCE):
			movement_controller.move_down(delta);
		elif (nav_delta.x < -MOVE_TOLERANCE):
			movement_controller.move_right(delta);
		elif (nav_delta.x > MOVE_TOLERANCE):
			movement_controller.move_left(delta);

func _has_reached_path() -> bool:
	var map := Blackboard.get_map();
	var nav_delta := movement_controller.moveable_character.global_position - map.get_position_from_tile(next_path_tile);
	if (
		nav_delta.x < MOVE_TOLERANCE && nav_delta.x > -MOVE_TOLERANCE && nav_delta.y < MOVE_TOLERANCE && nav_delta.y > -MOVE_TOLERANCE
	):
		return true;
		
	return false;

func _draw() -> void:
	var map := Blackboard.get_map();
	var tile_size := map.tile_map_layer.tile_set.tile_size;
	var half_tile_size := tile_size/2;
	if (current_tile_pos):
		var pos := to_local(map.get_position_from_tile(current_tile_pos));
		draw_rect(Rect2(pos.x - half_tile_size.x, pos.y - half_tile_size.y, tile_size.x, tile_size.y), Color.BLUE);

	if (target_tile_pos):
		var pos := to_local(map.get_position_from_tile(target_tile_pos));
		draw_rect(Rect2(pos.x - half_tile_size.x, pos.y - half_tile_size.y, tile_size.x, tile_size.y), Color.RED);

	if (next_path_tile):
		var pos := to_local(map.get_position_from_tile(next_path_tile));
		draw_rect(Rect2(pos.x - half_tile_size.x, pos.y - half_tile_size.y, tile_size.x, tile_size.y), Color.GREEN);
