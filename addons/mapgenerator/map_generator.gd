class_name MapGenerator extends RefCounted

var cell_generator := CellGenerator.new();
var tile_generator: TileGenerator;

var max_reruns = 100;

func run() -> void:
	var num_reruns = 0;
	run_until_ready(num_reruns);

func run_until_ready(current_run: int) -> void:
	cell_generator.run();
	# var resized_cells := _resize_dynamic();
	var resized_cells := _resize_static();

	if (!resized_cells.size()):
		if (current_run < max_reruns):
			current_run += 1;
			run_until_ready(current_run);
		else:
			print_debug("Reached max resize failures")
		return;

	tile_generator = TileGenerator.new(
		resized_cells,
		cell_generator.num_rows,
		cell_generator.num_columns
	);
	tile_generator.generate();

func _resize_dynamic() -> Array[Array]:
	var resizer := CellTileResizer.new(
		cell_generator.cells,
		cell_generator.num_rows,
		cell_generator.num_columns
	)
	var resized_cells := resizer.upscale();
	return resized_cells;

func _resize_static() -> Array[Array]:
	var tile_cells: Array[Array] = [];
	tile_cells.resize(cell_generator.num_columns);
	for x in range(cell_generator.num_columns):
		tile_cells[x] = [];
		tile_cells[x].resize(cell_generator.num_rows);
		for y in range(cell_generator.num_rows):
			var cell = cell_generator._get_cell(x, y);
			var tc := TileCell.from(cell);
			tc.x = tc.x * CellTileResizer.TILE_SCALE;
			tc.y = tc.y * CellTileResizer.TILE_SCALE;
			tile_cells[x][y] = tc;

	return tile_cells;