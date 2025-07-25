class_name ProjectilePool
extends ObjectPool

## Initialize the projectile pool
## @param projectile_scene: The projectile scene to instantiate
## @param initial_size: The initial number of projectiles to create
## @param auto_expand: Whether to automatically create new projectiles when the pool is empty
func _init(projectile_scene: PackedScene, initial_size: int = 15, auto_expand: bool = true):
	super(projectile_scene, initial_size, auto_expand)


## Get a projectile from the pool and reset its state
## @return: A projectile from the pool, or null if the pool is empty and auto_expand is false
func get_projectile() -> Area2D:
	var projectile = get_object() as Area2D
	if projectile:
		# Safely re-enable the area's collision detection.
		projectile.set_deferred("monitoring", true)
		
		# Find the collision shape and safely re-enable it.
		var shape = projectile.find_child("CollisionShape2D")
		if shape:
			shape.set_deferred("disabled", false)
			
		if projectile.has_method("reset"):
			projectile.reset()
			
	return projectile


## Return a projectile to the pool
## @param projectile: The projectile to return to the pool
func return_projectile(projectile: Area2D) -> void:
	# Safely disable the area's collision detection.
	projectile.set_deferred("monitoring", false)
	
	# Find the collision shape and safely disable it.
	var shape = projectile.find_child("CollisionShape2D")
	if shape:
		shape.set_deferred("disabled", true)
		
	return_object(projectile)
