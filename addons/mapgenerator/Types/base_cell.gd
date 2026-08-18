class_name BaseCell extends Resource

var id: int;
var filled: bool;
var group_id: int;
var x: int;
var y: int;
var connect: Array[bool];
var next: Array[BaseCell];

# TOOD
# @export var is_raise_heigh_candidate: bool;

func _init(
	p_x: int = -1,
	p_y: int = -1,
	p_id: int = -1,
	p_group_id: int = -1,
	p_filled: bool = false,
	p_connect: Array[bool] = [false, false, false, false],
	p_next: Array[BaseCell] = [null, null, null, null]
) -> void:
	id = p_id;
	filled = p_filled;
	group_id = p_group_id;
	x = p_x;
	y = p_y;
	connect = p_connect;
	next = p_next;
