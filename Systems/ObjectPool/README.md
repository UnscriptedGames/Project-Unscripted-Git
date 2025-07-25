# Object Pooling System

This system provides object pooling functionality for Project Unscripted, improving performance and memory management by reusing objects instead of constantly creating and destroying them.

## Benefits

- **Improved Performance**: Reduces CPU overhead from frequent instantiation/destruction
- **Reduced Memory Fragmentation**: Fewer allocations/deallocations means less memory fragmentation
- **Smoother Gameplay**: Fewer frame rate drops during intense gameplay with many enemies and projectiles
- **Better Memory Management**: More predictable memory usage patterns

## Components

The object pooling system consists of the following components:

1. **ObjectPool**: The base class that handles the core pooling functionality
2. **EnemyPool**: A specialized pool for enemy objects
3. **ProjectilePool**: A specialized pool for projectile objects
4. **PoolDebugger**: A debugging tool to monitor pool usage

## Usage

### Setting Up Pools

Pools are initialized in the main level:

```gdscript
# Initialize the enemy pool
_enemy_pool = EnemyPool.new(_enemy_scene, 20)
add_child(_enemy_pool)

# Initialize the pool debugger
_pool_debugger = PoolDebugger.new()
add_child(_pool_debugger)
```

### Getting Objects from Pools

To get an enemy from the pool:

```gdscript
var enemy_instance = _enemy_pool.get_enemy()
enemy_path.add_child(enemy_instance)
```

To get a projectile from the pool:

```gdscript
var projectile = _projectile_pool.get_projectile()
projectile.target = _current_target
projectile.speed = data.projectile_speed
projectile.damage = data.projectile_damage
projectile.global_position = muzzle.global_position
```

### Returning Objects to Pools

Objects are automatically returned to their pools when they're no longer needed. This is handled in the `base_enemy.gd` and `base_projectile.gd` scripts:

```gdscript
# Return to pool instead of queue_free
var pool = get_meta("pool") if has_meta("pool") else null
if pool and pool.has_method("return_enemy"):
	get_parent().remove_child(self)
	pool.return_enemy(self)
else:
	queue_free()
```

## Testing and Optimization

The `PoolDebugger` class provides a visual overlay that displays pool usage statistics:

- Number of available objects in each pool
- Number of objects currently in use
- Total number of objects in each pool

Use this information to optimize your pool sizes:

1. If a pool frequently runs out of available objects (causing new ones to be created), consider increasing the initial pool size.
2. If a pool has many objects that are never used, consider decreasing the initial pool size.

## Customization

### Adjusting Pool Sizes

You can adjust the initial pool sizes in the main level:

```gdscript
# For enemies
_enemy_pool = EnemyPool.new(_enemy_scene, 30)  # Increase to 30

# For projectiles
var new_pool = ProjectilePool.new(projectile_scene, 50)  # Increase to 50
```

### Auto-Expansion

By default, pools will automatically create new objects when they run out. You can disable this behavior:

```gdscript
_enemy_pool = EnemyPool.new(_enemy_scene, 20, false)  // Set auto_expand to false
```

When auto-expansion is disabled, the pool will emit a `pool_empty` signal when it runs out of objects.

### Debugging

You can toggle the debug overlay by setting the `show_debug_overlay` property:

```gdscript
_pool_debugger.show_debug_overlay = false  // Hide the debug overlay
```

## Performance Considerations

- Object pooling trades memory for performance. We pre-allocate objects to avoid the cost of instantiation during gameplay.
- Start with reasonable pool sizes and adjust based on testing. For enemies, consider the maximum number that might be active at once. For projectiles, consider fire rate and projectile lifetime.
- The pools can automatically expand if needed, but this should be monitored to prevent excessive memory usage.
