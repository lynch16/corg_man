class_name TileCell extends BaseCell

const TILE_SCALE = 3;

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
	width = p_w;
	height = p_h;

static func from(base_cell: BaseCell) -> TileCell:
	return TileCell.new(
		base_cell.x * TILE_SCALE,
		base_cell.y * TILE_SCALE,
		base_cell.id,
		base_cell.group_id,
		base_cell.filled,
		base_cell.connect,
		base_cell.next,
		3, 
		3 # TODO: Consider shrink width/height
	)
