extends CenterContainer

@export var draw_single_dead_end := true;
@export var single_dead_end_color := Color(255,255,0,0.4);

@export var draw_double_dead_end := true;
@export var double_dead_end_color := Color(0,255,255,0.2);

@export var draw_void_tunnel_candidate := true;
@export var void_tunnel_color := Color(0,0,0,0.2);

@export var draw_edge_tunnel_candidate := true;
@export var edge_tunnel_color := Color(0, 0, 0, 0.7);

@export var draw_selected_tunnel := true;
@export var selected_tunnel_color := Color(0, 255, 0, 0.7);

@export var draw_numbers := true;

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
				line_color,
				2.0,
			);
		if (!cell.connect[CellGenerator.DOWN]):
			draw_line(
				Vector2(x * draw_scale, y * draw_scale + draw_scale), 
				Vector2(x * draw_scale + draw_scale, y * draw_scale + draw_scale), 
				line_color,
				2.0,
			);
		if (!cell.connect[CellGenerator.LEFT]):
			draw_line(
				Vector2(x * draw_scale, y * draw_scale), 
				Vector2(x * draw_scale, y * draw_scale + draw_scale), 
				line_color,
				2.0,
			);
		if (!cell.connect[CellGenerator.RIGHT]):
			draw_line(
				Vector2(x * draw_scale + draw_scale, y * draw_scale), 
				Vector2(x * draw_scale + draw_scale, y * draw_scale + draw_scale), 
				line_color,
				2.0,
			);

		if (draw_numbers && cell.id != -1):
			draw_string(ThemeDB.fallback_font, Vector2(x * draw_scale + draw_scale/2 - 8, y * draw_scale + draw_scale/2 + 4), str(cell.id))

		if (draw_single_dead_end && cell.debug.is_single_dead_end_candidate):
			draw_rect(Rect2(x * draw_scale, y * draw_scale, draw_scale, draw_scale), single_dead_end_color);
		if (draw_double_dead_end && cell.debug.is_double_dead_end_candidate):
			draw_rect(Rect2(x * draw_scale, y * draw_scale, draw_scale, draw_scale), double_dead_end_color);
		if (draw_void_tunnel_candidate && cell.debug.is_void_tunnel_candidate):
			draw_rect(Rect2(x * draw_scale, y * draw_scale, draw_scale, draw_scale), void_tunnel_color);

		if (draw_selected_tunnel && cell.is_tunnel):
			draw_char(ThemeDB.fallback_font, Vector2(x * draw_scale + draw_scale/2 - 8, y * draw_scale + draw_scale/2 + 4), "^", 32, selected_tunnel_color);
		elif (draw_edge_tunnel_candidate && cell.debug.is_edge_tunnel_candidate):
			draw_char(ThemeDB.fallback_font, Vector2(x * draw_scale + draw_scale/2 - 8, y * draw_scale + draw_scale/2 + 4), "^", 32, edge_tunnel_color);
