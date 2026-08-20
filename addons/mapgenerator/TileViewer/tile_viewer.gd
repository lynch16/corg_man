@tool
extends Control

@export var grid_color := Color(0, 0, 0, 0.3);

@export var tile_null_color := Color(124, 0, 0, 0.1);
@export var tile_unassigned_color := Color(0, 124, 0, 0.1);
@export var tile_wall_color := Color(0, 255, 255, 0.1);
@export var tile_pellet_color := Color(255, 0, 0, 0.4);
@export var tile_energizer_color := Color(0, 255, 0, 0.4);
@export var tile_door_color := Color(255, 0, 255, 0.1);
@export var tile_blank_color := Color(0, 0, 0, 0.4);

var tile_color_map: Dictionary[TileGenerator.TileType, Color] = {
	TileGenerator.TileType.Null: tile_null_color,
	TileGenerator.TileType.Unassigned: tile_unassigned_color,
	TileGenerator.TileType.Wall: tile_wall_color,
	TileGenerator.TileType.Pellet: tile_pellet_color,
	TileGenerator.TileType.Energizer: tile_energizer_color,
	TileGenerator.TileType.Door: tile_door_color,
	TileGenerator.TileType.Blank: tile_blank_color
}

var tile_generator: TileGenerator;
var cell_generator: CellGenerator;

var has_loaded := false;

func _ready() -> void:
	pass;

func _on_cell_generator_run(p_cell_gen: CellGenerator) -> void:

	cell_generator = p_cell_gen;
	tile_generator = TileGenerator.new(
		cell_generator.cells,
		cell_generator.num_rows,
		cell_generator.num_columns
	);
	_gen();

func _gen() -> void:
	tile_generator.generate();
	has_loaded = true;

func _process(delta: float) -> void:
	if (has_loaded):
		queue_redraw();

func _draw() -> void:
	if (has_loaded):
		_draw_tiles();

func _draw_tiles() -> void:
	var draw_scale := 40; # TODO: Should this be consistent with TileViewer/CellViewer

	var subsize := draw_scale / 3;
	var num_subrows := tile_generator.num_rows * 3 + 1 + 3; # TODO: Why these nums
	var num_subcolumns := tile_generator.num_columns * 3 - 1 + 2;
	var num_full_columns := (num_subcolumns - 2) * 2;

	for i in range(num_subrows):
		var y := i * subsize;
		draw_line(
			Vector2(0, y),
			Vector2(num_full_columns * subsize, y),
			grid_color
		);

	for i in range(num_full_columns):
		var x := i * subsize;
		draw_line(
			Vector2(x, 0),
			Vector2(x, num_subrows * subsize),
			grid_color
		);

	for i in range(num_subrows * num_full_columns):
		var x := i % num_full_columns;
		var y = floori(i / num_full_columns);
		var color := tile_color_map[tile_generator.tiles[i]]

		draw_rect(
			Rect2(x * subsize, y * subsize, subsize, subsize),
			color,
		);