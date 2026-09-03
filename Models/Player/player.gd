class_name Player
extends CharacterBody2D

@export var movement_stats: MovementStats;
@export var health_stats: HealthStats;
@export var combat_stats: CombatStats;

@onready var hurtbox: Hurtbox2D = %Hurtbox2D;
@onready var movement_controller: MovementController = get_node("MovementController");

var damageable: Damageable;
var next_velocity: Vector2;
var next_rotation: float;

# TODO: Nothing listens to this
signal player_died(player: Player);

func _enter_tree() -> void:
	hurtbox = %Hurtbox2D;
	hurtbox.health_stats = health_stats;

func _ready() -> void:
	# Register broadcast handler and emit initial health state
	health_stats.on_health_changed.connect(_handle_player_damage);
	health_stats.on_health_depleted.connect(_die);
	
	# Call deferred so that Damageble handlers can connect before initial broadcast to HUD
	# SignalBus._on_player_health_updated(int(health_stats.current_health));

	movement_controller.movement_stats = movement_stats;

func _handle_player_damage(_old_health: float, new_health: float) -> void:
	# SignalBus._on_player_health_updated(int(new_health));
	pass;
	
func _die() -> void:
	var sprite: AnimatedSprite2D = $AnimatedShipSprite2D;
	sprite.hide();
	process_mode = Node.PROCESS_MODE_DISABLED;
	_notify_death();

func _notify_death() -> void:
	player_died.emit(self);
