@tool
extends Control

@export var grid_color := Color(0, 0, 0, 0.3);

@export var tile_null_color := Color(124, 0, 0, 0.1); # Light Red
@export var tile_unassigned_color := Color(0, 124, 0, 0.1); # Light green
@export var tile_wall_color := Color(0, 255, 255, 0.1); # Light blue
@export var tile_pellet_color := Color(255, 0, 0, 0.4); # Red
@export var tile_energizer_color := Color(0, 255, 0, 0.4);
@export var tile_door_color := Color(255, 0, 255, 0.1); # Pink
@export var tile_blank_color := Color(0, 0, 0, 0.4);

signal failed_resize();

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

var num_reruns := 0;
var max_reruns := 1000;

func _ready() -> void:
	pass;

func _on_cell_generator_run(p_cell_gen: CellGenerator) -> void:
	cell_generator = p_cell_gen;

	# _resize_and_gen();
	_resize_static();

func _resize_and_gen() -> void:
	var resizer := CellTileResizer.new(
		cell_generator.cells,
		cell_generator.num_rows,
		cell_generator.num_columns
	)
	var resized_cells := resizer.upscale();
	if (!resized_cells.size()):
		if (num_reruns < max_reruns):
			num_reruns += 1;
			failed_resize.emit();
		else:
			print_debug("Reached max resize failures")
		return;

	tile_generator = TileGenerator.new(
		resized_cells,
		resizer.num_rows,
		resizer.num_columns
	);
	_gen();

func _resize_static() -> void:
	var tile_cells: Array[TileCell] = [];
	for cell in cell_generator.cells:
		var tc := TileCell.from(cell);
		tc.x = tc.x * CellTileResizer.TILE_SCALE;
		tc.y = tc.y * CellTileResizer.TILE_SCALE;
		tile_cells.append(tc);
		
	tile_generator = TileGenerator.new(
		tile_cells,
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

	# TODO: Would this be easier if I convert this to a 2D array?

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
