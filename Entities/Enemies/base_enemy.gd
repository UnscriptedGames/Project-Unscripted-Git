extends PathFollow2D

## The data resource containing all stats for this enemy.
@export var data: EnemyData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $HealthBar

var _path: Path2D
var _current_health: float


func _ready() -> void:
	# Only run game logic if the data resource is assigned.
	if not data:
		return

	_path = get_parent()
	_current_health = data.max_health
	# Initialize the health bar and hide it.
	health_bar.update_health(_current_health, data.max_health)
	health_bar.visible = false


func take_damage(damage_amount: float) -> void:
	if not data:
		return
		
	_current_health -= damage_amount
	# Show the health bar and update it.
	health_bar.visible = true
	health_bar.update_health(_current_health, data.max_health)
	
	if _current_health <= 0:
		queue_free()


func _process(_delta: float) -> void:
	if not data or not is_instance_valid(_path):
		return

	progress += data.speed * _delta
	update_animation()

	if progress_ratio >= 1.0:
		queue_free()


func update_animation() -> void:
	var current_pos: Vector2 = _path.curve.sample_baked(progress)
	var future_pos: Vector2 = _path.curve.sample_baked(progress + 1.0)
	var direction: Vector2 = (future_pos - current_pos).normalized()
	var new_animation: StringName
	var new_flip: bool

	if direction.y < 0:
		new_animation = "walk_north_west"
	else:
		new_animation = "walk_south_west"

	if direction.x > 0:
		new_flip = true
	else:
		new_flip = false

	if animated_sprite.animation != new_animation:
		animated_sprite.play(new_animation)
	
	if animated_sprite.flip_h != new_flip:
		animated_sprite.flip_h = new_flip
