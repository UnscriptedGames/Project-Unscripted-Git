@tool
extends Area2D

## The data resource containing all stats for this tower.
@export var data: TowerData

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle

var _targets_in_range: Array = []
var _current_target = null


func _ready() -> void:
	# Only run game logic if the data resource is assigned.
	if not data:
		return
	
	shoot_timer.wait_time = 1.0 / data.fire_rate
	_update_range_shape()


func _physics_process(_delta: float) -> void:
	# Don't run targeting/shooting logic in the editor.
	if Engine.is_editor_hint() or not data:
		return
	
	_find_target()
	_try_to_shoot()


func _update_range_shape() -> void:
	if not data or not collision_shape or not collision_shape.shape:
		return
		
	# Use a temporary tile size for the shape calculation, not a constant.
	var tile_size := Vector2(130, 65)
	var half_width: float = (data.range_in_tiles + 0.5) * tile_size.x
	var half_height: float = (data.range_in_tiles + 0.5) * tile_size.y
	
	var points: PackedVector2Array = [
		Vector2(0, -half_height), Vector2(half_width, 0),
		Vector2(0, half_height), Vector2(-half_width, 0)
	]
	collision_shape.shape.set_points(points)


func _find_target() -> void:
	if not is_instance_valid(_current_target) or not _current_target in _targets_in_range:
		_current_target = null
	
	if not _current_target and not _targets_in_range.is_empty():
		_current_target = _targets_in_range[0]


func _try_to_shoot() -> void:
	if is_instance_valid(_current_target) and shoot_timer.is_stopped():
		_shoot()
		shoot_timer.start(1.0 / data.fire_rate)


func _shoot() -> void:
	if not data.projectile_scene:
		return
	
	var new_projectile = data.projectile_scene.instantiate()
	new_projectile.target = _current_target
	# Pass stats from the tower's data to the new projectile.
	new_projectile.speed = data.projectile_speed
	new_projectile.damage = data.projectile_damage
	
	new_projectile.global_position = muzzle.global_position
	get_tree().root.add_child(new_projectile)


func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	_targets_in_range.append(enemy)


func _on_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	_targets_in_range.erase(enemy)
