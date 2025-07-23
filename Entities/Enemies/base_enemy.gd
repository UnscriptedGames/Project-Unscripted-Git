extends PathFollow2D

## The data resource containing all stats for this enemy.
@export var data: EnemyData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $YSortContainer/HealthBar

var _current_health: float
var _path: Path2D


func _ready() -> void:
	# Only run game logic if the data resource is assigned.
	if not data:
		return

	_path = get_parent()
	_current_health = data.max_health

	# Initialize the health bar (if it exists) and hide it.
	if is_instance_valid(health_bar):
		health_bar.update_health(_current_health, data.max_health)
		health_bar.visible = false

	# Wait for the next process frame to ensure the node's position on the
	# path is ready, then set the initial animation.
	await get_tree().process_frame
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

	# Move the enemy along the path.
	progress += data.speed * delta

	# Update the sprite animation based on direction.
	update_animation()

	if progress_ratio >= 1.0:
		queue_free()


func update_animation() -> void:
	if not is_instance_valid(animated_sprite):
		return

	# This check is now crucial. We can't determine an animation
	# if the data isn't loaded.
	if not data:
		return

	var current_pos: Vector2 = _path.curve.sample_baked(progress)
	var future_pos: Vector2 = _path.curve.sample_baked(progress + 1.0)
	var direction: Vector2 = (future_pos - current_pos).normalized()
	var new_animation: StringName
	var new_flip: bool

	# Read the animation names from the data resource instead of hard-coding them.
	if direction.y < 0:
		new_animation = data.animation_walk_up
	else:
		new_animation = data.animation_walk_down

	if direction.x > 0:
		new_flip = true
	else:
		new_flip = false

	if animated_sprite.animation != new_animation:
		animated_sprite.play(new_animation)

	if animated_sprite.flip_h != new_flip:
		animated_sprite.flip_h = new_flip
