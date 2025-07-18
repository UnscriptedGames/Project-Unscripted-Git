extends Area2D

## The speed of the projectile in pixels per second.
@export var speed: float = 400.0
## The damage the projectile deals. We'll use this later.
@export var damage: float = 1.0

## The target the projectile will move towards. This is set by the tower.
var target: Node2D = null


func _physics_process(delta: float) -> void:
	# If the target is gone, destroy the projectile to prevent stray shots.
	if not is_instance_valid(target):
		queue_free()
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
		# Check if the enemy has the take_damage function before calling it.
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

		queue_free()
