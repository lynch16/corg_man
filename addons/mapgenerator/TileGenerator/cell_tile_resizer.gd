# Responsible for upscaling a cell map into a tile map, which is 1 row taller and 1 column narrower than the generated cell set
class_name CellTileResizer extends RefCounted

const TILE_SCALE = 3;

var cells: Array[Array];
var num_rows: int;
var num_columns: int;

## Dictionary with X coordinate as the key and Y coordinate as the value
var tall_rows: Dictionary[int, int];
## Dictionary with Y coordinate as the indkeyex and X coordiante as the value;
var narrow_columns: Dictionary[int, int];

func _init(
	p_cells: Array[Array],
	p_num_rows: int,
	p_num_columns: int,
) -> void:
	cells = p_cells;
	num_columns = p_num_columns;
	num_rows = p_num_rows;

func upscale() -> Array[Array]:
	_set_resize_candidates();
	_choose_tall_rows();
	_choose_narrow_columns();

	if !(tall_rows.size() > 0 && narrow_columns.size()):
		return [];

	var tile_cells: Array[Array] = [];
	tile_cells.resize(cells.size());

	for x in num_columns:
		tile_cells[x].resize(num_rows);

		for y in num_rows:
			var tile_cell := TileCell.from(_get_cell(x, y));
			var final_x := tile_cell.x * TILE_SCALE;;
			if (narrow_columns.has(tile_cell.y) && narrow_columns[tile_cell.y] < tile_cell.x):
				final_x -= 1;
			tile_cell.x = final_x;

			var final_y = tile_cell.y * TILE_SCALE;
			if (tall_rows.has(tile_cell.x) && tall_rows[tile_cell.x] < tile_cell.y):
				final_y += 1;
			tile_cell.y = final_y;

			tile_cell.width = 2 if tile_cell.shrink_width else 3;
			tile_cell.height = 4 if tile_cell.raise_height else 3;

			tile_cells[x][y] = tile_cell;

	return tile_cells;

func _set_resize_candidates() -> void:
	for x in num_columns:
		for y in num_rows:
			var cell := _get_cell(x, y);

			#  determine if it has flexible height

			# 
			#  |_|
			# 
			#  or
			#   _
			#  | |
			if (
				(cell.x == 0 || !cell.connect[CellGenerator.LEFT]) &&
				(cell.x == num_columns - 1 || !cell.connect[CellGenerator.RIGHT]) &&
				cell.connect[CellGenerator.UP] != cell.connect[CellGenerator.DOWN]
			):
				cell.is_raise_height_candidate = true;

			#   _ _
			#  |_ _|
			# 
			var right_cell := cell.next[CellGenerator.RIGHT];
			if (right_cell &&
				((cell.x == 0 || !cell.connect[CellGenerator.LEFT]) && !cell.connect[CellGenerator.UP] && !cell.connect[CellGenerator.DOWN]) &&
				((right_cell.x == num_columns - 1 || !right_cell.connect[CellGenerator.RIGHT]) && !right_cell.connect[CellGenerator.UP] && !right_cell.connect[CellGenerator.DOWN])
			):
				cell.is_raise_height_candidate = right_cell.is_raise_height_candidate;

			# Determine if width if flexible

			# if cell is on the right edge with an opening to the right
			if (cell.x == num_columns - 1 && cell.connect[CellGenerator.RIGHT]):
				cell.is_shrink_width_candidate = true;

			#   _
			#  |_
			#  
			#  or
			#   _
			#   _|
			# 
			if (
				(cell.y == 0 || !cell.connect[CellGenerator.UP]) &&
				(cell.y == num_rows - 1 || !cell.connect[CellGenerator.DOWN]) &&
				cell.connect[CellGenerator.LEFT] != cell.connect[CellGenerator.RIGHT]
			):
				cell.is_shrink_width_candidate = true;

func _choose_tall_rows() -> void:
	# From top left, find a row that can be raised before hitting the ghost house
	for y in range(3):
		var cell := _get_cell(0, y);
		if (cell.is_raise_height_candidate && _can_raise_height(0, y)):
			cell.raise_height = true;
			tall_rows[cell.x] = cell.y;
			break;

func _can_raise_height(x: int, y: int) -> bool:
	## At end of map so safe to expand
	if (x == num_columns - 1):
		return true;
	
	# Count row from this one row upwards to top row
	# to find cell that will create too tight right turn
	var selected_cell: BaseCell;
	var right_cell: BaseCell;

	for row_index in range(y, -1, -1):
		selected_cell = _get_cell(x, row_index);
		right_cell = selected_cell.next[CellGenerator.RIGHT];
		if (
			(!selected_cell.connect[CellGenerator.UP] || _is_cell_cross_center(selected_cell)) &&
			(!right_cell.connect[CellGenerator.UP] || _is_cell_cross_center(right_cell))
		):
			break;

	# Using the right cell, move down to find a cell that is a raise candidate
	var raise_candidates: Array[BaseCell] = [];
	var down_cell := right_cell;
	while (down_cell):
		if (down_cell.is_raise_height_candidate):
			raise_candidates.append(down_cell);

		# Cant go any further down
		if (
			(!down_cell.connect[CellGenerator.DOWN] || _is_cell_cross_center(down_cell)) &&
			(!down_cell.next[CellGenerator.LEFT].connect[CellGenerator.DOWN] || _is_cell_cross_center(down_cell.next[CellGenerator.LEFT]))
		):
			break;

		down_cell = down_cell.next[CellGenerator.DOWN];

	# TODO: Shuffle candidates
	for selection in raise_candidates:
		if (_can_raise_height(selection.x, selection.y)):
			selection.raise_height = true;
			tall_rows[selection.x] = selection.y;
			return true;

	return false;

func _choose_narrow_columns() -> void:
	# Count columns from outside in
	for x in range(num_columns - 1, -1, -1):
		var cell := _get_cell(x, 0);
		if (cell.is_shrink_width_candidate && _can_shrink_width(x, 0)):
			cell.shrink_width = true;
			narrow_columns[cell.y] = cell.x;
			break;

func _can_shrink_width(x: int, y: int) -> bool:
	## At end of map so safe to expand
	if (y == num_rows - 1):
		return true;

	# Walk on the right hand side of cells
	var selected_cell: BaseCell;
	var down_cell: BaseCell;
	for column_index in range(x, num_columns):
		selected_cell = _get_cell(column_index, y);
		down_cell = selected_cell.next[CellGenerator.DOWN];
		if (
			(!selected_cell.connect[CellGenerator.RIGHT] || _is_cell_cross_center(selected_cell)) &&
			(!down_cell.connect[CellGenerator.RIGHT] || _is_cell_cross_center(down_cell))
		):
			break;

	# Collect candidates until cant go any further
	var left_candidates: Array[BaseCell];
	var left_cell := down_cell;
	while (left_cell):
		if (left_cell.is_shrink_width_candidate):
			left_candidates.append(left_cell);

		if (
			(!left_cell.connect[CellGenerator.LEFT] || _is_cell_cross_center(left_cell)) &&
			(!left_cell.next[CellGenerator.UP].connect[CellGenerator.LEFT] || _is_cell_cross_center(left_cell.next[CellGenerator.UP]))
		):
			break;

		left_cell = left_cell.next[CellGenerator.LEFT];

	# TODO: Shuffle candidates;
	
	for selection in left_candidates:
		if (_can_shrink_width(selection.x, selection.y)):
			selection.shrink_width = true;
			narrow_columns[selection.y] = selection.x;
			return true;
	
	return false;

func _is_cell_cross_center(cell: BaseCell) -> bool:
	return cell.connect[CellGenerator.UP] && \
		cell.connect[CellGenerator.RIGHT] && \
		cell.connect[CellGenerator.DOWN] &&  \
		cell.connect[CellGenerator.LEFT];

# Get the base tile at coordinates
func _get_cell(x: int, y: int) -> BaseCell:
	return cells[x][y];
