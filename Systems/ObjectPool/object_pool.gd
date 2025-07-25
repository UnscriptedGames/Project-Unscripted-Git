class_name ObjectPool
extends Node2D

## Signal emitted when trying to get an object but the pool is empty and auto_expand is false
signal pool_empty

## The scene used to instantiate objects for this pool
var _scene: PackedScene

## Array of objects that are available for use
var _available_objects: Array = []

## Array of objects that are currently in use
var _in_use_objects: Array = []

## The initial size of the pool
var _pool_size: int

## Whether the pool should automatically expand when empty
var _auto_expand: bool


## Initialize the object pool
## @param scene: The scene to instantiate objects from
## @param initial_size: The initial number of objects to create
## @param auto_expand: Whether to automatically create new objects when the pool is empty
func _init(scene: PackedScene, initial_size: int = 10, auto_expand: bool = true) -> void:
	_scene = scene
	_pool_size = initial_size
	_auto_expand = auto_expand
	_initialize_pool()


## Create the initial objects for the pool
func _initialize_pool() -> void:
	for i in range(_pool_size):
		var object = _create_object()
		_available_objects.append(object)
		object.visible = false


## Create a new object from the scene
## @return: The newly created object
func _create_object() -> Node:
	var object = _scene.instantiate()
	# Add a reference back to the pool for easy return
	object.set_meta("pool", self)
	return object


# In file: Systems/ObjectPool/object_pool.gd

## Get an object from the pool
## @return: An object from the pool, or null if the pool is empty and auto_expand is false
func get_object() -> Node:
	# Declare the variable once at the function scope to avoid shadowing.
	var object: Node

	if _available_objects.is_empty():
		if _auto_expand:
			# Assign to the 'object' variable and return it immediately.
			object = _create_object()
			_in_use_objects.append(object)
			return object
		else:
			emit_signal("pool_empty")
			return null
	
	# Assign the pre-warmed object from the available list.
	object = _available_objects.pop_back()
	_in_use_objects.append(object)
	
	object.visible = true
	return object


# In file: Systems/ObjectPool/object_pool.gd

## Return an object to the pool
## @param p_object: The object to return to the pool
func return_object(p_object: Node) -> void:
	# Check if the object is actually in use before returning it.
	if not p_object in _in_use_objects:
		return

	_in_use_objects.erase(p_object)
	_available_objects.append(p_object)
	p_object.visible = false



## Get the number of available objects in the pool
func get_available_count() -> int:
	return _available_objects.size()


## Get the number of objects currently in use
func get_in_use_count() -> int:
	return _in_use_objects.size()


## Get the total number of objects in the pool
func get_total_count() -> int:
	return get_available_count() + get_in_use_count()
