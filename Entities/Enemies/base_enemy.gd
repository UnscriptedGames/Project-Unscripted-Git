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
var is_defeated: bool = false

func _ready() -> void:
	# Get the animated sprite using the path we assign in the editor.
	if animated_sprite_path:
		_animated_sprite = get_node(animated_sprite_path)

	# Only run game logic if the data resource is assigned.
	if not data:
		return

	# _path = get_parent() # <-- REMOVE THIS LINE
	_current_health = data.max_health

	# Initialize the health bar (if it exists) and hide it.
	if is_instance_valid(health_bar):
		health_bar.update_health(_current_health, data.max_health)
		health_bar.visible = false

	# Call update_animation directly. No await needed.
	update_animation()


# In file: Entities/Enemies/base_enemy.gd

func take_damage(damage_amount: float) -> void:
	if not data:
		return

	_current_health = max(_current_health - damage_amount, 0)

	# Show the health bar and update it.
	if is_instance_valid(health_bar):
		health_bar.visible = true
		health_bar.update_health(_current_health, data.max_health)

	# Only return to pool if health is 0 (not on first hit)
	if _current_health <= 0:
		is_defeated = true
		var pool = get_meta("pool") if has_meta("pool") else null
		if pool and pool.has_method("return_enemy"):
			# The enemy must remove itself from its parent (e.g., EnemyPath).
			get_parent().remove_child(self)
			pool.return_enemy(self)
		else:
			queue_free()


func _process(delta: float) -> void:
	if not data:
		return

	# If we don't have a path yet, try to get one from our parent.
	if not is_instance_valid(_path):
		var p = get_parent()
		# Only assign the path if the parent is actually a Path2D node.
		if p is Path2D:
			_path = p
		else:
			# If we are not on a path, we cannot move, so stop here.
			return

	# Process movement along the path.
	progress += data.speed * delta
	update_animation()

	# If the enemy reaches the end of the path, return it to the pool.
	if progress_ratio >= 1.0:
		is_defeated = true
		var pool = get_meta("pool") if has_meta("pool") else null
		if pool and pool.has_method("return_enemy"):
			# The enemy must remove itself from its parent (e.g., EnemyPath).
			get_parent().remove_child(self)
			pool.return_enemy(self)
		else:
			queue_free()


func update_animation() -> void:
	# Use the _animated_sprite variable we set in _ready.
	if not is_instance_valid(_animated_sprite):
		return

	if not data or not is_instance_valid(_path):
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


# In file: Entities/Enemies/base_enemy.gd

## Reset the enemy state when it's retrieved from the pool
func reset() -> void:
	# Reset the defeated state for the enemy's new life.
	is_defeated = false

	_path = null
	progress = 0

	if data:
		_current_health = data.max_health
		if is_instance_valid(health_bar):
			health_bar.update_health(_current_health, data.max_health)
			health_bar.visible = false
			
	# Force the animation to play again when an enemy is reused.
	if is_instance_valid(_animated_sprite):
		_animated_sprite.play()
