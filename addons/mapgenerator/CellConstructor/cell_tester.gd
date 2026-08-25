class_name CellTester extends RefCounted

var num_columns: int;
var num_rows: int;
var cells: Array[Array]

func _get_cell(x: int, y: int) -> BaseCell:
	return cells[x][y];

func test_cell_gen(p_rows: int, p_columns: int, p_cells: Array[Array]) -> bool:
	cells = p_cells;
	num_columns = p_columns;
	num_rows = p_rows;

	# Ensure solid top right corner
	var cell := _get_cell(num_columns - 1, 0);
	if (cell.connect[CellGenerator.UP] || cell.connect[CellGenerator.RIGHT]):
		return false;

	# Ensure solid bottom right corner
	cell = _get_cell(num_columns - 1, num_rows - 1);
	if (cell.connect[CellGenerator.DOWN] || cell.connect[CellGenerator.RIGHT]):
		return false;

	var is_horiz_cell = func(x: int, y: int) -> bool:
		var q1 := _get_cell(x, y).connect;
		var q2 := _get_cell(x + 1, y).connect;
		return !q1[CellGenerator.UP] && !q1[CellGenerator.DOWN] && (x == 0 || !q1[CellGenerator.LEFT]) && q1[CellGenerator.RIGHT] && \
				!q2[CellGenerator.UP] && !q2[CellGenerator.DOWN] && q2[CellGenerator.LEFT] && !q2[CellGenerator.RIGHT];

	var is_vert_cell = func(x: int, y: int) -> bool:
		var q1 := _get_cell(x, y).connect;
		var q2 := _get_cell(x, y + 1).connect;
		if (x == num_columns - 1):
			# Special case (we can consider two single cells as vertical at the right edge)
			return !q1[CellGenerator.LEFT] && !q1[CellGenerator.UP] && !q1[CellGenerator.DOWN] && \
					!q2[CellGenerator.LEFT] && !q2[CellGenerator.UP] && !q2[CellGenerator.DOWN];
		
		return !q1[CellGenerator.LEFT] && !q1[CellGenerator.RIGHT] && !q1[CellGenerator.UP] && q1[CellGenerator.DOWN] && \
			   !q2[CellGenerator.LEFT] && !q2[CellGenerator.RIGHT] && q2[CellGenerator.UP] && !q2[CellGenerator.DOWN];

	var group: int;
	# Ensure there are no two stacked/side-by-side 2-cell pieces.
	# Instead convert to a square
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
				var c := _get_cell(x, y)
				c.connect[CellGenerator.DOWN] = true;
				c.connect[CellGenerator.RIGHT] = true;
				group = c.group_id;

				c = _get_cell(x + 1, y)
				c.connect[CellGenerator.DOWN] = true;
				c.connect[CellGenerator.LEFT] = true;
				c.group_id = group;

				c = _get_cell(x, y + 1)
				c.connect[CellGenerator.UP] = true;
				c.connect[CellGenerator.RIGHT] = true;
				c.group_id = group;

				c = _get_cell(x + 1, y + 1)
				c.connect[CellGenerator.UP] = true;
				c.connect[CellGenerator.LEFT] = true;
				c.group_id = group;

	if (!_check_no_full_width_path()):
		return false;

	return true;

func _check_no_full_width_path() -> bool:
	for y in range(num_rows):
		var cell := _get_cell(num_columns - 1, y);
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
