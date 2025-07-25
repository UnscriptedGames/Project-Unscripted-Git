class_name PoolDebugger
extends CanvasLayer

## Whether to show the debug overlay
@export var show_debug_overlay: bool = true

## The update interval in seconds
@export var update_interval: float = 1.0

## Reference to the main level
var _main_level: Node

## Timer for updating the stats
var _update_timer: Timer

## Labels for displaying pool stats
var _enemy_pool_label: Label
var _projectile_pools_label: Label


func _ready() -> void:
	if not show_debug_overlay:
		return
	
	# Find the main level
	var main_level_nodes = get_tree().get_nodes_in_group("main_level")
	if main_level_nodes.size() > 0:
		_main_level = main_level_nodes[0]
	
	# Create the debug UI
	_create_debug_ui()
	
	# Create and start the update timer
	_update_timer = Timer.new()
	_update_timer.wait_time = update_interval
	_update_timer.autostart = true
	_update_timer.timeout.connect(_update_stats)
	add_child(_update_timer)
	
	# Update stats immediately
	_update_stats()


## Create the debug UI
func _create_debug_ui() -> void:
	# Create a container for the debug UI
	var container = VBoxContainer.new()
	container.position = Vector2(10, 10)
	container.size = Vector2(300, 200)
	add_child(container)
	
	# Add a title
	var title = Label.new()
	title.text = "Object Pool Debug"
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 2)
	container.add_child(title)
	
	# Add a label for the enemy pool
	_enemy_pool_label = Label.new()
	_enemy_pool_label.text = "Enemy Pool: N/A"
	_enemy_pool_label.add_theme_color_override("font_color", Color.WHITE)
	_enemy_pool_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_enemy_pool_label.add_theme_constant_override("outline_size", 1)
	container.add_child(_enemy_pool_label)
	
	# Add a label for the projectile pools
	_projectile_pools_label = Label.new()
	_projectile_pools_label.text = "Projectile Pools: N/A"
	_projectile_pools_label.add_theme_color_override("font_color", Color.WHITE)
	_projectile_pools_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_projectile_pools_label.add_theme_constant_override("outline_size", 1)
	container.add_child(_projectile_pools_label)


## Update the pool stats
func _update_stats() -> void:
	if not _main_level:
		return
	
	# Update enemy pool stats
	if "_enemy_pool" in _main_level and is_instance_valid(_main_level._enemy_pool):
		var pool = _main_level._enemy_pool
		_enemy_pool_label.text = "Enemy Pool: %d available, %d in use (total: %d)" % [
			pool.get_available_count(),
			pool.get_in_use_count(),
			pool.get_total_count()
		]
	
	# Update projectile pool stats
	if "_projectile_pools" in _main_level:
		var pools_text = "Projectile Pools:\n"
		var pools = _main_level._projectile_pools
		
		if pools.is_empty():
			pools_text += "  None active"
		else:
			for scene_path in pools:
				var pool = pools[scene_path]
				var scene_name = scene_path.get_file().get_basename()
				pools_text += "  %s: %d available, %d in use (total: %d)\n" % [
					scene_name,
					pool.get_available_count(),
					pool.get_in_use_count(),
					pool.get_total_count()
				]
		
		_projectile_pools_label.text = pools_text
