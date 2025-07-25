extends Area2D

## The speed of the projectile in pixels per second.
@export var speed: float = 400.0
## The damage the projectile deals. We'll use this later.
@export var damage: float = 1.0

## The target the projectile will move towards. This is set by the tower.
var target: Node2D = null


func _physics_process(delta: float) -> void:
	# If the target is gone OR defeated, return the projectile to the pool.
	if not is_instance_valid(target) or target.is_defeated:
		# Defer the return logic to run at a safe time.
		call_deferred("_return_to_pool")
		return

	# Recalculate the direction to the target every frame to home in.
	var direction = (target.global_position - global_position).normalized()

	# Set the projectile's rotation to match its direction.
	rotation = direction.angle() + deg_to_rad(90)

	# Move the projectile in the new direction.
	global_position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()

	# Only register a hit if the enemy we hit is our intended target.
	if enemy == target:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

		# Defer the return logic to run at a safe time.
		call_deferred("_return_to_pool")

## Encapsulates the logic for returning the projectile to its pool.
func _return_to_pool() -> void:
	# First, check if the node is still active in the scene tree.
	# This is a safer check that prevents errors from deferred calls.
	if not is_inside_tree():
		return

	var pool = get_meta("pool") if has_meta("pool") else null
	if pool and pool.has_method("return_projectile"):
		# Now that we know it's safe, remove the node from its parent.
		get_parent().remove_child(self)
		pool.return_projectile(self)
	else:
		queue_free()
		

## Reset the projectile state when it's retrieved from the pool
## Reset the projectile state when it's retrieved from the pool
func reset() -> void:
	target = null
	# Reset the z_index back to its default value.
	z_index = 0
	speed = 400.0
	damage = 1.0
