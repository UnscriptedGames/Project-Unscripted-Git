@tool
extends Area2D

## The data resource containing all stats for this tower.
@export var data: TowerData

## If true, the tower is a non-functional "ghost" for placement.
var is_ghost: bool = false:
	set(new_value):
		is_ghost = new_value
		# This code now runs automatically whenever 'is_ghost' is changed.
		if is_inside_tree():
			if is_instance_valid(range_indicator):
				range_indicator.visible = is_ghost

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle
@onready var range_indicator: Polygon2D = $RangeIndicator

var _targets_in_range: Array = []
var _current_target = null
var _projectile_pool: ProjectilePool
var _projectiles_container: Node2D

func _ready() -> void:
	# The setter for is_ghost handles visibility changes after creation.
	# This line handles the initial visibility when the node first enters the scene.
	if is_instance_valid(range_indicator):
		range_indicator.visible = is_ghost
	
	if not data:
		return
	_update_range_shape()


func _physics_process(_delta: float) -> void:
	if is_ghost or Engine.is_editor_hint() or not data:
		return
	_find_target()
	_try_to_shoot()


func _update_range_shape() -> void:
	if not data or not collision_shape or not collision_shape.shape:
		return
	var tile_size := Vector2(130, 65)
	var half_width: float = (data.range_in_tiles + 0.5) * tile_size.x
	var half_height: float = (data.range_in_tiles + 0.5) * tile_size.y
	var points: PackedVector2Array = [
		Vector2(0, -half_height), Vector2(half_width, 0),
		Vector2(0, half_height), Vector2(-half_width, 0)
	]
	collision_shape.shape.set_points(points)
	range_indicator.polygon = points


func _find_target() -> void:
	if not is_instance_valid(_current_target) or not _current_target in _targets_in_range:
		_current_target = null
	if not _current_target and not _targets_in_range.is_empty():
		var furthest_enemy = _targets_in_range[0]
		for i in range(1, _targets_in_range.size()):
			var next_enemy = _targets_in_range[i]
			if next_enemy.progress > furthest_enemy.progress:
				furthest_enemy = next_enemy
		_current_target = furthest_enemy


func _try_to_shoot() -> void:
	if is_instance_valid(_current_target) and shoot_timer.is_stopped():
		_shoot()
		shoot_timer.start(1.0 / data.fire_rate)

# In file: Entities/Towers/base_tower.gd

# In file: Entities/Towers/base_tower.gd

# In file: Entities/Towers/base_tower.gd

func _shoot() -> void:
	if not data.projectile_scene:
		return
	
	# We need a reference to the main level to get the pool and the container.
	# We assume there is only one "main_level" node in the scene.
	var main_level_nodes = get_tree().get_nodes_in_group("main_level")
	if main_level_nodes.is_empty():
		return # Can't shoot if we can't find the main level.
	
	var main_level = main_level_nodes[0]

	# Get the projectile pool from the main level.
	if not _projectile_pool and main_level.has_method("get_projectile_pool"):
		_projectile_pool = main_level.get_projectile_pool(data.projectile_scene)

	# Get a projectile, which should be parentless at this point.
	var projectile
	if _projectile_pool:
		projectile = _projectile_pool.get_projectile()
	else:
		projectile = data.projectile_scene.instantiate()
	
	if not projectile:
		return

	# Get the container for projectiles, which is the YSort node.
	if not is_instance_valid(_projectiles_container):
		_projectiles_container = main_level.get_node("YSortContainer")

	# Add the projectile to the scene tree ONCE.
	if is_instance_valid(_projectiles_container):
		_projectiles_container.add_child(projectile)
	else:
		# Fallback to the root if the container isn't found.
		get_tree().root.add_child(projectile)

	# Configure the projectile's properties.
	projectile.target = _current_target
	projectile.z_index = 1
	projectile.speed = data.projectile_speed
	projectile.damage = data.projectile_damage
	projectile.global_position = muzzle.global_position
	projectile.visible = true
	

func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	_targets_in_range.append(enemy)


func _on_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	_targets_in_range.erase(enemy)
