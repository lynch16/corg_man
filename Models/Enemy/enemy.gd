class_name Enemy
extends CharacterBody2D

@export var health_stats: HealthStats;
@export var combat_stats: CombatStats;

@onready var vision_area: VisionArea = get_node("VisionArea");
@onready var nav_controller: AStarGridNavController = $NavController;

var damageable: Damageable;
var tracked_opponents: Array[Node2D] = [];

var hurtbox: Hurtbox2D;
var hitbox: Hitbox2D;

signal target_acquired(target: Node2D);

func _enter_tree() -> void:
	hurtbox = $Hurtbox2D;
	hurtbox.health_stats = health_stats;

	hitbox = $Hitbox2D
	hitbox.attacker_combat_stats = combat_stats;

func _physics_process(delta: float) -> void:
	_chase_player(delta);

func _chase_player(delta: float) -> void:
	var map := Blackboard.get_map();
	var player := Blackboard.get_player();
	if (!player): return;

	var player_tile_pos := map.get_tile_from_position(player.global_position);

	nav_controller.set_nav_target(Vector2i(player_tile_pos.x , player_tile_pos.y));
	nav_controller._calculate_next_nav_path();
	nav_controller.move_next_in_path(delta);


# func _ready() -> void:
# 	health_stats.on_health_depleted.connect(_die);
# 	vision_area.on_visible_objects_updated.connect(_track_opponents);

# func _track_opponents(tracked_opps: Array[Node2D]) -> void:
# 	if (tracked_opps.hash() != tracked_opponents.hash()):
# 		tracked_opponents = tracked_opps;
# 		# TODO: Using just the first opponent is sloppy but doesn't matter with just one Player
# 		target_acquired.emit(tracked_opponents[0]);

# func set_move_position(new_position: Vector2) -> void:
# 	move_controller.update_nav_target(new_position);

# func set_start_velocity(_velocity: Vector2) -> void:
# 	velocity = _velocity;
# 	move_controller.update_nav_velocity(_velocity);

# func _die() -> void:
# 	move_controller.process_mode = Node.PROCESS_MODE_DISABLED;
# 	var sprite: AnimatedSprite2D = $AnimatedSprite2D;
# 	sprite.hide();
# 	get_tree().create_timer(1.0, false).timeout.connect(queue_free);
