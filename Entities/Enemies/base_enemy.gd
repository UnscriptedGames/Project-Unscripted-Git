extends PathFollow2D

## The data resource containing all stats for this enemy.
@export var data: EnemyData

## A path to the AnimatedSprite2D node for this enemy.
## We will assign this in the editor for each specific enemy scene.
@export var animated_sprite_path: NodePath

@onready var health_bar: TextureProgressBar = $YSortContainer/HealthBar

var _current_health: float
var _path: Path2D
# We will get the actual sprite node in _ready.
var _animated_sprite: AnimatedSprite2D


func _ready() -> void:
	# Get the animated sprite using the path we assign in the editor.
	if animated_sprite_path:
		_animated_sprite = get_node(animated_sprite_path)

	# Only run game logic if the data resource is assigned.
	if not data:
		return

	_path = get_parent()
	_current_health = data.max_health

	# Initialize the health bar (if it exists) and hide it.
	if is_instance_valid(health_bar):
		health_bar.update_health(_current_health, data.max_health)
		health_bar.visible = false

	# Call update_animation directly. No await needed.
	update_animation()


func take_damage(damage_amount: float) -> void:
	if not data:
		return

	_current_health -= damage_amount

	# Show the health bar and update it.
	if is_instance_valid(health_bar):
		health_bar.visible = true
		health_bar.update_health(_current_health, data.max_health)

	if _current_health <= 0:
		queue_free()


func _process(delta: float) -> void:
	if not data or not is_instance_valid(_path):
		return

	progress += data.speed * delta
	update_animation()

	if progress_ratio >= 1.0:
		queue_free()


func update_animation() -> void:
	# Use the _animated_sprite variable we set in _ready.
	if not is_instance_valid(_animated_sprite):
		return

	if not data:
		return

	var current_pos: Vector2 = _path.curve.sample_baked(progress)
	var future_pos: Vector2 = _path.curve.sample_baked(progress + 1.0)
	var direction: Vector2 = (future_pos - current_pos).normalized()
	var new_animation: StringName
	var new_flip: bool

	if direction.y < 0:
		new_animation = data.animation_walk_up
	else:
		new_animation = data.animation_walk_down

	if direction.x > 0:
		new_flip = true
	else:
		new_flip = false

	if _animated_sprite.animation != new_animation:
		_animated_sprite.play(new_animation)

	if _animated_sprite.flip_h != new_flip:
		_animated_sprite.flip_h = new_flip
