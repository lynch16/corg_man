extends CenterContainer

var generator: CellGenerator;

func _ready() -> void:
	generator = CellGenerator.new();
	generator.run();

func _process(delta: float) -> void:
	queue_redraw();

func _draw() -> void:
	_draw_cells();

func _draw_cells() -> void:
	var line_color := Color.RED;
	var draw_scale := 40;

	for y in generator.num_rows:
		draw_line(
			Vector2(0, y * draw_scale),
			Vector2(generator.num_columns * draw_scale, y * draw_scale),
			Color.DIM_GRAY
		);
	
	for x in generator.num_columns:
		draw_line(
			Vector2(x * draw_scale, 0),
			Vector2(x * draw_scale, generator.num_rows * draw_scale),
			Color.DIM_GRAY
		);

	for i in range(generator.num_columns * generator.num_rows):
		var cell := generator.cells[i];
		var x := i % generator.num_columns;
		var y = floor(i / generator.num_columns);

		if (!cell.connect[CellGenerator.UP]):
			draw_line(
				Vector2(x * draw_scale, y * draw_scale), 
				Vector2(x * draw_scale + draw_scale, y * draw_scale), 
				line_color
			);
		if (!cell.connect[CellGenerator.DOWN]):
			draw_line(
				Vector2(x * draw_scale, y * draw_scale + draw_scale), 
				Vector2(x * draw_scale + draw_scale, y * draw_scale + draw_scale), 
				line_color
			);
		if (!cell.connect[CellGenerator.LEFT]):
			draw_line(
				Vector2(x * draw_scale, y * draw_scale), 
				Vector2(x * draw_scale, y * draw_scale + draw_scale), 
				line_color
			);
		if (!cell.connect[CellGenerator.RIGHT]):
			draw_line(
				Vector2(x * draw_scale + draw_scale, y * draw_scale), 
				Vector2(x * draw_scale + draw_scale, y * draw_scale + draw_scale), 
				line_color
			);

		if (cell.id != -1):
			draw_string(ThemeDB.fallback_font, Vector2(x * draw_scale + draw_scale/2, y * draw_scale + draw_scale/2), str(cell.id))

		
