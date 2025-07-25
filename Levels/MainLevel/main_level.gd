# res://Project-Unscripted-Git/Levels/MainLevel/main_level.gd
extends Node2D

## The scene for the fire tower we want to build.
@export var fire_tower_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_path: Path2D = $YSortContainer/EnemyPath
@onready var tile_map: TileMapLayer = $YSortContainer/GroundLayer

var _ghost_tower = null
var _placed_towers: Array = []

# Object pooling variables
var _enemy_scene = preload("res://Project-Unscripted-Git/Entities/Enemies/test_enemy.tscn")
var _enemy_pool: EnemyPool
var _projectile_pools = {}
var _pool_debugger: PoolDebugger

func _ready() -> void:
	# Add this node to a group so towers can find it
	add_to_group("main_level")
	
	# Initialize the enemy pool
	_enemy_pool = EnemyPool.new(_enemy_scene, 20)
	add_child(_enemy_pool)
	
	# Initialize the pool debugger
	_pool_debugger = PoolDebugger.new()
	add_child(_pool_debugger)
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)



# In file: Levels/MainLevel/main_level.gd

func _on_spawn_timer_timeout() -> void:
	# Get an enemy from the pool instead of instantiating
	var enemy_instance = _enemy_pool.get_enemy()
	
	# Add the enemy to the path
	enemy_path.add_child(enemy_instance)


func _on_button_pressed() -> void:
	if is_instance_valid(_ghost_tower):
		return

	_ghost_tower = fire_tower_scene.instantiate()
	_ghost_tower.is_ghost = true
	add_child(_ghost_tower)
	_update_ghost_position()


func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(_ghost_tower):
		return

	if event is InputEventMouseMotion:
		_update_ghost_position()
	
	# Handle left-click to place the tower.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var tile_coord: Vector2i = tile_map.local_to_map(_ghost_tower.global_position)
		if _is_placement_valid(tile_coord):
			_place_tower(tile_coord)
		else:
			print("Cannot build here!")
			
	# Handle right-click to cancel.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_ghost_tower.queue_free()
		_ghost_tower = null
		print("Build cancelled.")


func _update_ghost_position() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var tile_coord: Vector2i = tile_map.local_to_map(mouse_pos)
	_ghost_tower.global_position = tile_map.map_to_local(tile_coord)
	
	var visuals = _ghost_tower.get_node("Visuals")
	
	# Check if the current tile is valid and change colour accordingly.
	if _is_placement_valid(tile_coord):
		# Set to 75% transparent white (valid).
		visuals.self_modulate = Color(1.0, 1.0, 1.0, 0.85)
	else:
		# Set to 75% transparent red (invalid).
		visuals.self_modulate = Color(1.0, 0.6, 0.6, 0.85)


func _is_placement_valid(tile_coord: Vector2i) -> bool:
	# Check 1: Is the tile buildable?
	var tile_data = tile_map.get_cell_tile_data(tile_coord)
	if not tile_data or not tile_data.get_custom_data("buildable"):
		return false # Tile is not of the 'buildable' type.
		
	# Check 2: Is the tile already occupied by another tower?
	for tower in _placed_towers:
		var tower_coord: Vector2i = tile_map.local_to_map(tower.global_position)
		if tower_coord == tile_coord:
			return false # Tile is occupied.
			
	return true


func _place_tower(tile_coord: Vector2i) -> void:
	# Make the tower "real".
	_ghost_tower.is_ghost = false
	_ghost_tower.get_node("Visuals").self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	# Set its final position.
	_ghost_tower.global_position = tile_map.map_to_local(tile_coord)
	
	# Add this line to move the tower into the sorting container.
	_ghost_tower.reparent($YSortContainer)
	
	# Add it to our list of placed towers.
	_placed_towers.append(_ghost_tower)
	
	# Clear the ghost reference so we can build another one.
	_ghost_tower = null
	print("Tower placed!")


## Get or create a projectile pool for a specific scene
## @param projectile_scene: The projectile scene to get a pool for
## @return: The projectile pool for the given scene
func get_projectile_pool(projectile_scene: PackedScene) -> ProjectilePool:
	var scene_path = projectile_scene.resource_path
	if not _projectile_pools.has(scene_path):
		var new_pool = ProjectilePool.new(projectile_scene, 30)
		add_child(new_pool)
		_projectile_pools[scene_path] = new_pool
	return _projectile_pools[scene_path]
