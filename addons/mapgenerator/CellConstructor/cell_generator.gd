class_name CellGenerator extends RefCounted

const UP = 0;
const RIGHT = 1;
const DOWN = 2;
const LEFT = 3;



var prob_stop_growing_at_size := [ # probability of stopping growth at sizes...
	0,     # size 0
	0,     # size 1
	0.10,  # size 2
	0.5,   # size 3
	0.75,  # size 4
	1,	   # size 5
];    
var prob_top_and_bottom_single_cell_join := 0.35;
var prob_extend_leg_size_2 := 1.0;
var prob_extend_leg_size_3_4 := 0.5;

var cells: Array[BaseCell];
var max_cell_size := 5;
var max_long_pieces := 1;

var cell_tester := CellTester.new();
var num_rows := 9;
var num_columns := 5;

func run() -> void:
	var generate_count := 0;
	while(generate_count < 100):
		reset_map();
		generate_map();
		generate_count += 1;
		if (!cell_tester.test_cell_gen(num_rows, num_columns, cells)):
			continue;
		
		break;
	
	print("TOTAL GENERATED: " + str(generate_count));

func reset_map() -> void:
	cells.resize(num_rows * num_columns)
	for i in range(num_rows * num_columns):
		cells[i] = BaseCell.new(
			i % num_columns,
			floor(i / num_columns)
		)
	
	# allow each cell to refer to surround cells by direction
	for i in range(num_rows * num_columns):
		var c := cells[i];
		if (c.x > 0):
			c.next[LEFT] = cells[i - 1];
		if (c.x < num_columns - 1):
			c.next[RIGHT] = cells[i + 1];
		if (c.y > 0):
			c.next[UP] = cells[i - num_columns];
		if (c.y < num_rows - 1):
			c.next[DOWN] = cells[i + num_columns];

	# define the ghost home square
	var i := 3 * num_columns;
	var c := cells[i];
	c.filled=true;
	c.connect[LEFT] = true
	c.connect[RIGHT] = true
	c.connect[DOWN] = true;

	i += 1
	c = cells[i];
	c.filled=true;
	c.connect[LEFT] = true
	c.connect[DOWN] = true;

	i += num_columns-1;
	c = cells[i];
	c.filled=true;
	c.connect[LEFT] = true;
	c.connect[UP] = true;
	c.connect[RIGHT] = true;

	i += 1
	c = cells[i];
	c.filled=true;
	c.connect[UP] = true;
	c.connect[LEFT] = true;


func generate_map() -> void:
	var next_direction: int = -1;
	var next_cell: BaseCell;

	var num_filled := 1;
	var num_groups := 0;
	var long_pieces := 0;

	# A single cell group of size 1 is allowed at each row at y=0 and y=rows-1,
	# so keep count of those created.
	var single_count = {};
	single_count[0] = single_count[num_rows - 1] if single_count.has(num_rows - 1) else 0;

	while (true):
		var open_cells := _get_left_most_empty_cells();

		# Stop iterating when no more cells;
		var num_open_cells := open_cells.size();
		if (num_open_cells == 0):
			break;

		# choose the center cell to be a random open cell, and fill it.
		var random_cell_id := randi() % num_open_cells;
		var random_cell := open_cells[random_cell_id];
		var first_cell := random_cell;
		_fill_cell(random_cell, num_filled, num_groups);
		num_filled += 1;

		# randomly allow one single-cell piece on the top or bottom of the map.
		if (
			random_cell.x < num_columns - 1 && 
			(random_cell.y in single_count) &&
			randf() <= prob_top_and_bottom_single_cell_join
		):
			if (single_count[random_cell.y] == 0):
				random_cell.connect[UP if random_cell.y == 0 else DOWN] = true;
				single_count[random_cell.y] += 1;
				continue;
			
		# number of cells in this contiguous group
		var size := 1;

		if (random_cell.x == num_columns - 1):
			# if the first cell is at the right edge, then don't grow it.
			random_cell.connect[RIGHT] = true;
			# TODO
			# random_cell.is_raise_height_candidate = true;
		else:
			while (size < max_cell_size):
				var stop := false;

				if (size == 2):
					# With a horizontal 2-cell group, try to turn it into a 4-cell "L" group.
					# This is done here because this case cannot be reached when a piece has already grown to size 3.

					var cell := first_cell;
					if (cell.x > 0 && cell.connect[RIGHT] && cell.next[RIGHT] && cell.next[RIGHT].next[RIGHT]):
						if (long_pieces < max_long_pieces && randf() <= prob_extend_leg_size_2):
							cell = cell.next[RIGHT].next[RIGHT];

							var directions := [];
							directions.resize(4);
							directions.fill(false)

							if (_is_open_cell(cell, UP)):
								directions[UP] = true;
							if (_is_open_cell(cell, DOWN)):
								directions[DOWN] = true;

							if (directions[UP] && directions[DOWN]):
								next_direction = [UP, DOWN][randi() % 2];
							elif (directions[UP]):
								next_direction = UP;
							elif (directions[DOWN]):
								next_direction = DOWN;
							
							if (next_direction >= 0):
								_connect_cell(cell, LEFT);
								_fill_cell(cell, num_filled, num_groups);
								num_filled += 1;
								_connect_cell(cell, next_direction);
								_fill_cell(cell.next[next_direction], num_filled, num_groups);
								num_filled += 1;

								long_pieces += 1;
								size += 2;
								stop = true;

				if (!stop):
					# find available open adjacent cells.
					var open_cell_directions := _get_open_surrounding_cell_directions(random_cell, next_direction, size);

					# if no open cells found from center point, then use the last cell as the new center
					# but only do this if we are of length 2 to prevent numerous short pieces.
					# then recalculate the open adjacent cells.
					if (open_cell_directions.size() == 0 && size == 2):
							random_cell = next_cell;
							open_cell_directions = _get_open_surrounding_cell_directions(random_cell, next_direction, size);

					# no more adjacent cells, so stop growing this piece.
					if (open_cell_directions.size() == 0):
						stop = true;
					else:
						# choose a random valid direction to grow.
						next_direction = open_cell_directions[randi() % open_cell_directions.size()];
						next_cell = random_cell.next[next_direction];
						
						# connect the cell to the new cell. Fill it and increase count size.
						_connect_cell(random_cell, next_direction);
						_fill_cell(next_cell, num_filled, num_groups);
						num_filled += 1;
						size += 1;

						# don't let center pieces grow past 3 cells
						if (first_cell.x == 0 && size == 3):
							stop = true;

						# Use a probability to determine when to stop growing the piece.
						if (randf() <= prob_stop_growing_at_size[size]):
							stop = true;

				if (stop):
					if (size == 1):
						print_debug("Error: Called stop after one cell");
					elif (size == 2):
						# With a vertical 2-cell group, attach to the right wall if adjacent.
						var c := first_cell;
						if (c.x == num_columns - 1):
							if (c.connect[UP]):
								c = c.next[UP];

							c.connect[RIGHT] = true;
							c.next[DOWN].connect[RIGHT] = true;
					elif (size == 3 || size == 4):
						
						# Try to extend group to have a long leg
						if (long_pieces < max_long_pieces && first_cell.x > 0 && randf() <= prob_extend_leg_size_3_4):
							var directions: Array[int] = [];
							for i in range(4):
								if (random_cell.connect[i] && _is_open_cell(random_cell.next[i], i)):
									directions.append(i);

							if (directions.size() > 0):
								var random_dir = directions[randi() % directions.size()];
								var next_c := random_cell.next[random_dir];
								_connect_cell(next_c, random_dir);
								_fill_cell(next_c.next[random_dir], num_filled, num_groups);
								num_filled += 1;
								long_pieces += 1;

					break;
	
		num_groups += 1;

func _fill_cell(cell: BaseCell, cell_number: int, group_number: int) -> void:
	cell.filled = true;
	cell.id = cell_number;
	cell.group_id = group_number;

func _get_left_most_empty_cells() -> Array[BaseCell]:
	var left_empty_cells: Array[BaseCell] = [];

	for x in range(num_columns):
		for y in range(num_rows):
			var cell = cells[x + y * num_columns];
			if (!cell.filled):
				left_empty_cells.append(cell);

		# Stop after first column if found empty cell
		if (left_empty_cells.size() > 0):
			break;
			
	return left_empty_cells;

func _is_open_cell(
	cell: BaseCell,
	direction_to_check: int, # UP, RIGHT, DOWN, LEFT
	# TODO: Prevent long straight peices of length 3
	previous_direction: int = -1, # UP, RIGHT, DOWN, LEFT
	cell_group_size: int = 0
) -> bool:
	# Dont create cell's through required starting position (wall)
	if ((cell.y == 6 && cell.x == 0 && direction_to_check == DOWN) ||
		(cell.y == 7 && cell.x == 0 && direction_to_check == UP)):
		return false;

	if (cell_group_size == 2 && (direction_to_check == previous_direction || (direction_to_check + 2) % 4 == previous_direction)):
		return false;

	if (cell.next[direction_to_check] && !cell.next[direction_to_check].filled):
		if (cell.next[direction_to_check].next[LEFT] && !cell.next[direction_to_check].next[LEFT].filled):
			pass;
		else:
			return true;

	return false;

func _get_open_surrounding_cell_directions(
	center_cell: BaseCell,
	previous_direction: int,
	size: int,
) -> Array[int]:
	var open_cell_directions: Array[int] = [];

	# range is 4 for the cardinal directions
	for direction in range(4):
		if (_is_open_cell(center_cell, direction, previous_direction, size)):
			open_cell_directions.append(direction);

	return open_cell_directions;

func _connect_cell(
	cell: BaseCell,
	direction: int
) -> void:
	# Connect to and connect back
	cell.connect[direction] = true;
	cell.next[direction].connect[(direction + 2) % 4] = true;

	# If connecting from first column to the right, put a wall up on the left
	# TODO: Check with and without this
	if (cell.x == 0 && direction == RIGHT):
		cell.connect[LEFT] = true;
