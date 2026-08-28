class_name MapGenerator extends RefCounted

var cell_generator := CellGenerator.new();
var tile_generator: TileGenerator;

var max_reruns = 100;

func run() -> void:
	var num_reruns = 0;
	run_until_ready(num_reruns);

func run_until_ready(current_run: int) -> void:
	cell_generator.run();
	
	var resizer := CellTileResizer.new(
		cell_generator.cells,
		cell_generator.num_rows,
		cell_generator.num_columns
	)
	var resized_cells := resizer.upscale();
	if (!resized_cells.size()):
		if (current_run < max_reruns):
			current_run += 1;
			run_until_ready(current_run);
		else:
			print_debug("Reached max resize failures")
		return;

	tile_generator = TileGenerator.new(
		resized_cells,
		resizer.num_rows,
		resizer.num_columns
	);
	tile_generator.generate();
