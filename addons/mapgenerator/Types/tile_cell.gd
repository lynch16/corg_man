class_name TileCell extends BaseCell


var width: int;
var height: int;

func _init(
	p_x: int = -1,
	p_y: int = -1,
	p_id: int = -1,
	p_group_id: int = -1,
	p_filled: bool = false,
	p_connect: Array[bool] = [false, false, false, false],
	p_next: Array[BaseCell] = [null, null, null, null],
	p_is_tunnel: bool = false,
	p_raise_height: bool = false,
	p_shrink_width: bool = false,
	p_w: int = -1,
	p_h: int = -1,
) -> void:
	id = p_id;
	filled = p_filled;
	group_id = p_group_id;
	x = p_x;
	y = p_y;
	connect = p_connect;
	next = p_next;
	is_tunnel = p_is_tunnel;
	raise_height = p_raise_height;
	shrink_width = p_shrink_width;
	width = p_w;
	height = p_h;

static func from(base_cell: BaseCell) -> TileCell:
	return TileCell.new(
		base_cell.x,
		base_cell.y,
		base_cell.id,
		base_cell.group_id,
		base_cell.filled,
		base_cell.connect,
		base_cell.next,
		base_cell.is_tunnel,
		base_cell.raise_height,
		base_cell.shrink_width,
		3, 
		3 # TODO: Consider shrink width/height
	)
