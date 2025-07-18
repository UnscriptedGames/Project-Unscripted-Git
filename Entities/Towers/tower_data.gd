class_name TowerData
extends Resource

## The tower's range in tiles.
@export var range_in_tiles: int = 1

## How many shots the tower fires per second.
@export var fire_rate: float = 1.0

## The projectile scene this tower will shoot.
@export var projectile_scene: PackedScene

## The speed of the projectiles fired by this tower.
@export var projectile_speed: float = 400.0

## The damage of the projectiles fired by this tower.
@export var projectile_damage: float = 50.0
