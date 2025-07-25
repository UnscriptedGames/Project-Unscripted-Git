class_name EnemyPool
extends ObjectPool

## Initialize the enemy pool
## @param enemy_scene: The enemy scene to instantiate
## @param initial_size: The initial number of enemies to create
## @param auto_expand: Whether to automatically create new enemies when the pool is empty
func _init(enemy_scene: PackedScene, initial_size: int = 10, auto_expand: bool = true):
	super(enemy_scene, initial_size, auto_expand)


## Get an enemy from the pool and reset its state
## @return: An enemy from the pool, or null if the pool is empty and auto_expand is false
func get_enemy() -> PathFollow2D:
	var enemy = get_object() as PathFollow2D
	if enemy:
		# The reset function now handles all state changes.
		if enemy.has_method("reset"):
			enemy.reset()
	return enemy


## Return an enemy to the pool
## @param enemy: The enemy to return to the pool
func return_enemy(enemy: PathFollow2D) -> void:
	return_object(enemy)
