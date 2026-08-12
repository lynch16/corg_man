class_name CellConstructor
extends MarginContainer

const CELL_SIZE_PX = 64;
const X_CELLS = 5;
const Y_CELLS = 9;
const LINE_CELL_WIDTH = 1;

var grid: GridContainer;

func _enter_tree() -> void:
	grid = $GridContainer;

	for x in range(X_CELLS):
		for y in range(Y_CELLS):
			var new_cell = CellButton.new();
			var size := Vector2i(CELL_SIZE_PX, CELL_SIZE_PX);
			new_cell.custom_maximum_size = size;
			new_cell.custom_minimum_size = size;
			new_cell.coordinates = Vector2i(x, y);
			grid.add_child(new_cell);