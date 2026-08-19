class_name CellTester extends RefCounted

var num_columns: int;
var num_rows: int;
var cells: Array[BaseCell]

func test_cell_gen(p_rows: int, p_columns: int, p_cells: Array[BaseCell]) -> bool:
	cells = p_cells;
	num_columns = p_columns;
	num_rows = p_rows;

	# Ensure solid top right corner
	var cell := cells[4];
	if (cell.connect[CellGenerator.UP] || cell.connect[CellGenerator.RIGHT]):
		return false;

	# Ensure solid bottom right corner
	cell = cells[num_rows * num_columns - 1];
	if (cell.connect[CellGenerator.DOWN] || cell.connect[CellGenerator.RIGHT]):
		return false;

	# Ensure there are no two stacked/side-by-side 2-cell pieces.
	var is_horiz_cell = func(x: int, y: int) -> bool:
		var q1 := cells[x + (y * num_columns)].connect;
		var q2 := cells[(x + 1) + (y * num_columns)].connect;
		return !q1[CellGenerator.UP] && !q1[CellGenerator.DOWN] && (x == 0 || !q1[CellGenerator.LEFT]) && q1[CellGenerator.RIGHT] && \
				!q2[CellGenerator.UP] && !q2[CellGenerator.DOWN] && q2[CellGenerator.LEFT] && !q2[CellGenerator.RIGHT];

	var is_vert_cell = func(x: int, y: int) -> bool:
		var q1 := cells[x + (y * num_columns)].connect;
		var q2 := cells[x + ((y + 1) * num_columns)].connect;
		if (x == num_columns - 1):
			# Special case (we can consider two single cells as vertical at the right edge)
			return !q1[CellGenerator.LEFT] && !q1[CellGenerator.UP] && !q1[CellGenerator.DOWN] && \
					!q2[CellGenerator.LEFT] && !q2[CellGenerator.UP] && !q2[CellGenerator.DOWN];
		
		return !q1[CellGenerator.LEFT] && !q1[CellGenerator.RIGHT] && !q1[CellGenerator.UP] && q1[CellGenerator.DOWN] && \
			   !q2[CellGenerator.LEFT] && !q2[CellGenerator.RIGHT] && q2[CellGenerator.UP] && !q2[CellGenerator.DOWN];

	var group: int;
	for y in range(num_rows - 1):
		for x in range(num_columns - 1):
			if (
				(is_horiz_cell.call(x, y) && is_horiz_cell.call(x, y + 1)) ||
				(is_vert_cell.call(x, y) && is_vert_cell.call(x + 1, y))
			):

				# don't allow them in the middle because they'll be two large when reflected.
				if (x == 0):
					return false;

				# Join the four cells to create a square.
				cells[x + y * num_columns].connect[CellGenerator.DOWN] = true;
				cells[x + y * num_columns].connect[CellGenerator.RIGHT] = true;
				group = cells[x + y * num_columns].group_id;

				cells[x + 1 + y * num_columns].connect[CellGenerator.DOWN] = true;
				cells[x + 1 + y * num_columns].connect[CellGenerator.LEFT] = true;
				cells[x + 1 + y * num_columns].group_id = group;

				cells[x + (y + 1) * num_columns].connect[CellGenerator.UP] = true;
				cells[x + (y + 1) * num_columns].connect[CellGenerator.RIGHT] = true;
				cells[x + (y + 1) * num_columns].group_id = group;

				cells[x + 1 + (y + 1) * num_columns].connect[CellGenerator.UP] = true;
				cells[x + 1 + (y + 1) * num_columns].connect[CellGenerator.LEFT] = true;
				cells[x + 1 + (y + 1) * num_columns].group_id = group;

	# TODO
	# Make sure the map contains cells that can grow/shrink to final size
	# if (!_has_height_grow_cell()):
	# 	return false;
	# if (!_has_width_shrink_cell()):
	# 	return false;
	# TODO: don't allow a horizontal path to cut straight through a map (through tunnels)
	if (!_check_no_full_width_path()):
		return false;

	return true;

func _check_no_full_width_path() -> bool:
	for y in range(num_rows):
		var cell := cells[num_columns - 1 + y * num_columns];
		if (cell.is_tunnel):
			var exit := true;
			var topY := cell.y;

			while(cell.next[CellGenerator.LEFT]):
				cell = cell.next[CellGenerator.LEFT];
				if (!cell.connect[CellGenerator.UP] && cell.y == topY):
					continue;
				else:
					exit = false;
					break;

			if (exit):
				return false;
	
	return true;
