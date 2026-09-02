class_name TileGenerator extends RefCounted

const TOP_WALL_ROW_OFFSET = 1;
const GHOST_HOUSE_COLUMN_OFFSET = 2;

# TODO: Set shrink and raise offsets to 1 when using resizer
const COLUMN_SHRINK_OFFSET = 0;
const ROW_RAISE_OFFSET = 0;

enum TileType {
	Null = -1,
	Unassigned = 0,
	Wall = 1,
	Pellet = 2,
	Energizer = 3,
	Door = 4,
	Blank = 5,
}

## Generated cells, upscaled to full size
var cells: Array[Array];
## Generated Tiles
var tiles: Array[Array];
## Map of tile coordinates to generated cell
var tile_cells: Array[Array];
## Number of rows used in generation
var num_cell_rows: int;
## Number of columns used in generation
var num_cell_columns: int;

var num_tile_rows: int;
var num_tile_columns: int;
var num_mid_columns: int;
var num_full_columns: int;

func _init(
	p_cells: Array[Array] = [],
	p_num_rows: int = 0,
	p_num_columns: int = 0
) -> void:
	cells = p_cells;
	num_cell_rows = p_num_rows;
	num_cell_columns = p_num_columns;

	num_tile_rows = num_cell_rows * CellTileResizer.TILE_SCALE + ROW_RAISE_OFFSET + 3; # Given num_cell_rows == 9, this will be 31
	num_tile_columns = num_cell_columns * CellTileResizer.TILE_SCALE - COLUMN_SHRINK_OFFSET + GHOST_HOUSE_COLUMN_OFFSET; # Given num_cell_columns == 5, this will be 16 (half + ghost house)
	num_mid_columns = num_tile_columns - GHOST_HOUSE_COLUMN_OFFSET; # Subtract the ghost house
	num_full_columns = num_mid_columns * 2; # Double for final width

func generate() -> void:
	tiles = [];
	tiles.resize(num_full_columns);
	
	tile_cells = [];
	tile_cells.resize(num_tile_columns);

	for x in range(num_full_columns):
		tiles[x] = [];
		tiles[x].resize(num_tile_rows);
		tiles[x].fill(TileType.Unassigned);

	for x in range(num_tile_columns):
		tile_cells[x] = [];
		tile_cells[x].resize(num_tile_rows);
		tile_cells[x].fill(null);

	for x in range(num_cell_columns):
		for y in range(num_cell_rows):
			var cell := _get_cell(x, y);
			for tile_x in range(cell.width):
				for tile_y in range(cell.height):
					# Adding 1 to offset top row with row of walls
					_set_tile_cell(cell.x + tile_x, cell.y + TOP_WALL_ROW_OFFSET + tile_y, cell);

	_set_path_tiles();
	_extend_tunnels();
	_set_ghost_house();
	_fill_walls();
	

	# _set_energizers();
	_clean_path_tunnels_and_ghost_house();

func _set_path_tiles() -> void:
	for y in range(num_tile_rows):
		for x in range(num_tile_columns):
			var cell := _get_tile_cell(x, y); 
			var cell_left := _get_tile_cell(x - 1, y);
			var cell_up := _get_tile_cell(x, y - 1);

			var valid_left := _cell_valid(cell_left);
			var valid_up := _cell_valid(cell_up);

			# Set tiles within cell map
			if (_cell_valid(cell)):
				if (
					valid_left && cell.group_id != cell_left.group_id || # Vertical boundary
					valid_up && cell.group_id != cell_up.group_id || # Horizontal boundary
					!valid_up && !cell.connect[CellGenerator.UP] # Top Boundary
				):
					_set_tile(x, y, TileType.Pellet);
					pass;
			else:
				# Set tiles outside cell map
				if (
					valid_left && (!cell_left.connect[CellGenerator.RIGHT] || _get_tile(x - 1, y) == TileType.Pellet) || # Right boundary
					valid_up && (!cell_up.connect[CellGenerator.DOWN] || _get_tile(x, y - 1) == TileType.Pellet) # Left boundary
				):
					_set_tile(x, y, TileType.Pellet);
					pass;

			# Corner connecting two paths
			if (
				_get_tile(x - 1, y) == TileType.Pellet &&
				_get_tile(x, y - 1) == TileType.Pellet &&
				(_get_tile(x - 1, y - 1) == TileType.Null || _get_tile(x - 1, y - 1) == TileType.Unassigned)
			):
				_set_tile(x, y, TileType.Pellet);

func _extend_tunnels() -> void:
	var end_column_cell := _get_cell(num_cell_columns - 1, 0);
	while (_cell_valid(end_column_cell)):
		if (end_column_cell.is_tunnel):
			var y = end_column_cell.y * CellTileResizer.TILE_SCALE + TOP_WALL_ROW_OFFSET;
			_set_tile(num_tile_columns - 1, y, TileType.Pellet);
			_set_tile(num_tile_columns - 2, y, TileType.Pellet);

		var next_cell_down := end_column_cell.next[CellGenerator.DOWN];
		if (next_cell_down):
			end_column_cell = TileCell.from(next_cell_down);
		else:
			end_column_cell = null;

func _fill_unassigned_as_walls() -> void:
	for y in range(num_tile_rows):
		for x in range(num_tile_columns):
			if (_get_tile(x, y) == TileType.Unassigned):
				_set_tile(x, y, TileType.Wall);

func _fill_walls() -> void:
	for y in range(num_tile_rows):
		for x in range(num_tile_columns):
			# Unassigned tiles that share vertex with path tiles are walls
			# Check all tiles in circular pattern (fill in corners)
			if (_get_tile(x, y) == TileType.Unassigned && (
					_get_tile(x - 1, y) == TileType.Pellet ||
					_get_tile(x + 1, y) == TileType.Pellet ||
					_get_tile(x, y - 1) == TileType.Pellet ||
					_get_tile(x, y + 1) == TileType.Pellet ||
					_get_tile(x - 1, y - 1) == TileType.Pellet ||
					_get_tile(x + 1, y - 1) == TileType.Pellet ||
					_get_tile(x + 1, y + 1) == TileType.Pellet ||
					_get_tile(x - 1, y + 1) == TileType.Pellet
			)):
				_set_tile(x, y, TileType.Wall);

func _set_ghost_house() -> void:
	# TODO: Make this parametric with generator somehow
	var top_ghost_row := 12 - TOP_WALL_ROW_OFFSET;
	var center_ghost_column := 2;
	var ghost_house_height := 3;
	var ghost_house_half_width := 3;

	# Set house walls on top and bottom. 
	for x1 in range(ghost_house_half_width):
		var x := x1 + center_ghost_column;
		_set_tile(x, top_ghost_row, TileType.Wall);
		_set_tile(x, top_ghost_row + ghost_house_height + 1, TileType.Wall);

		for y1 in range(ghost_house_height):
			var y := y1 + top_ghost_row + 1; # Add 1 here to account for top ghost house wall
			_set_tile(x, y, TileType.Blank);

	# Set house walls on sides
	for y1 in range(ghost_house_height + 2):
		var y := y1 + top_ghost_row;
		_set_tile(center_ghost_column + ghost_house_half_width, y, TileType.Wall);

	# Set pellets (path) around house - top and bottom
	for x1 in range(ghost_house_half_width + 1):
		var x := x1 + center_ghost_column;
		_set_tile(x, top_ghost_row - 1, TileType.Pellet);
		_set_tile(x, top_ghost_row + ghost_house_height + 2, TileType.Pellet);

	# Set pellets (path) around house - sides
	for y1 in range(ghost_house_height + 4):
		var y := y1 + top_ghost_row - 1;
		_set_tile(
			center_ghost_column + ghost_house_half_width + 1,
			y,
			TileType.Pellet
		)

	_set_tile(center_ghost_column, top_ghost_row, TileType.Door);
	

func _set_energizers() -> void:
	pass;

func _clean_path_tunnels_and_ghost_house() -> void:
	# Erase in tunnels
	var edge_x := num_tile_columns - 1;
	for y in range(num_tile_rows):
		if (_get_tile(edge_x, y) == TileType.Pellet):
			_erase_until_intersection(edge_x, y);

	# Erase at starting position
	# TODO: This should be parameterized
	_set_tile(1, num_tile_rows - 8 - ROW_RAISE_OFFSET, TileType.Blank);

	# Erase around ghost house
	for column_index in range(7):
		# TODO: This should be parameterized
		var bottom_house_row := num_tile_rows - 14 - ROW_RAISE_OFFSET;
		_set_tile(column_index, bottom_house_row, TileType.Blank);

		var bottom_row_offset := 1;
		# erase pellets from bottom of the ghost house proceeding down until
		# reaching a pellet tile that isn't surround by walls
		# on the left and right
		while (
			_get_tile(column_index, bottom_house_row + bottom_row_offset) == TileType.Pellet && \
			_get_tile(column_index - 1, bottom_house_row + bottom_row_offset) == TileType.Wall && \
			_get_tile(column_index + 1, bottom_house_row + bottom_row_offset) == TileType.Wall
		):
			_set_tile(column_index, bottom_house_row + bottom_row_offset, TileType.Blank);
			bottom_row_offset += 1;

		# TODO: This should be parameterized
		var top_house_row := num_tile_rows - 20 - ROW_RAISE_OFFSET;
		_set_tile(column_index, top_house_row, TileType.Blank);

		var top_row_offset := 1;
		# erase pellets from top of the ghost house proceeding up until
		# reaching a pellet tile that isn't surround by walls
		# on the left and right
		while (
			_get_tile(column_index, top_house_row + top_row_offset) == TileType.Pellet && \
			_get_tile(column_index - 1, top_house_row + top_row_offset) == TileType.Wall && \
			_get_tile(column_index + 1, top_house_row + top_row_offset) == TileType.Wall
		):
			_set_tile(column_index, top_house_row + top_row_offset, TileType.Blank);
			top_row_offset += 1;

		# Erase pellets on the side of the ghost house
		# TODO: This should be parameterized
		var side_x := 6;
		var side_row := num_tile_rows - 14 - column_index - ROW_RAISE_OFFSET;
		_set_tile(side_x, side_row, TileType.Blank);

		var side_row_offset := 1;
		# erase pellets from side of the ghost house proceeding right until
		# reaching a pellet tile that isn't surround by walls
		# on the top and bottom.
		while (
			_get_tile(side_x, side_row + side_row_offset) == TileType.Pellet && \
			_get_tile(side_x - 1, side_row + side_row_offset) == TileType.Wall && \
			_get_tile(side_x + 1, side_row + side_row_offset) == TileType.Wall
		):
			_set_tile(side_x, side_row + side_row_offset, TileType.Blank);
			side_row_offset += 1;

func _erase_until_intersection(x: int, y: int) -> void:
	var cells_to_edit: Array = [];
	if (_get_tile(x - 1, y) == TileType.Pellet):
		cells_to_edit.append({
			"x": x - 1,
			"y": y
		});
	if (_get_tile(x + 1, y) == TileType.Pellet):
		cells_to_edit.append({
			"x": x + 1,
			"y": y
		});
	if (_get_tile(x, y - 1) == TileType.Pellet):
		cells_to_edit.append({
			"x": x,
			"y": y - 1
		});
	if (_get_tile(x, y + 1) == TileType.Pellet):
		cells_to_edit.append({
			"x": x,
			"y": y + 1
		});

	if (cells_to_edit.size() == 1):
		_set_tile(x, y, TileType.Blank);
		x = cells_to_edit[0].x;
		y = cells_to_edit[0].y;
		return _erase_until_intersection(x, y);

# Get the base tile at coordinates
func _get_cell(x: int, y: int) -> BaseCell:
	return cells[x][y];

# Sets tile by applying tile type symetrically around the middle column
func _set_tile(x: int, y: int, tile_type: TileType) -> void:
	# Make sure tile is being set in half 
	if (x < 0 || x > num_tile_columns - 1 || y < 0 || y > num_tile_rows - 1):
		return;
	
	var normalized_x := x - GHOST_HOUSE_COLUMN_OFFSET;
	tiles[num_mid_columns + normalized_x][y] = tile_type;
	tiles[num_mid_columns - 1 - normalized_x][y] = tile_type;

func _get_tile(x: int, y: int) -> TileType:
	# Make sure tile is selecting for only half since mirrored
	if (x < 0 || x > num_tile_columns - 1 || y < 0 || y > num_tile_rows - 1):
		return TileType.Null;
	
	var normalized_x := x - GHOST_HOUSE_COLUMN_OFFSET;
	return tiles[num_mid_columns + normalized_x][y];

func _set_tile_cell(x: int, y: int, cell: TileCell) -> void:
	# Make sure tile cell is being set in half 
	if (x < 0 || x > num_tile_columns - 1 || y < 0 || y > num_tile_rows - 1):
		return;
	
	var normalized_x := x - GHOST_HOUSE_COLUMN_OFFSET;
	tile_cells[normalized_x][y] = cell;

func _get_tile_cell(x: int, y: int) -> TileCell:
	# Make sure tile is selecting for only half since mirrored
	if (x < 0 || x > num_tile_columns - 1 || y < 0 || y > num_tile_rows - 1):
		return TileCell.new();
	
	var normalized_x := x - GHOST_HOUSE_COLUMN_OFFSET;
	return tile_cells[normalized_x][y];
	
# Need to check IDs instead of null b/c of strict typing
func _cell_valid(cell: TileCell) -> bool:
	return cell && cell.id != -1;
