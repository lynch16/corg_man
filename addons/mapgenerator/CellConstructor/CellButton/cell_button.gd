class_name CellButton extends Button 

var style: StyleBoxFlat = load("uid://c54m1r17v6kqe");

var button_style: StyleBoxFlat;

@export var is_filled: bool;
var coordinates: Vector2i;

signal cell_filled(coordinates: Vector2i);
signal cell_cleared(coordinates: Vector2i);

func _enter_tree() -> void:
	button_style = style.duplicate_deep();
	add_theme_stylebox_override("normal", button_style);
	add_theme_stylebox_override("normal", button_style);

func _ready() -> void:
	pressed.connect(_on_pressed);

func _on_pressed() -> void:
	print("CLICKED")
	if (is_filled):
		is_filled = false;
		button_style.bg_color = Color.RED;
		cell_cleared.emit(coordinates)
	else:
		is_filled = true;
		button_style.bg_color = Color.BLUE;
		cell_filled.emit(coordinates);

