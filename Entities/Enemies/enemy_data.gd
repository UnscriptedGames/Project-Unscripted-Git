class_name EnemyData
extends Resource

## The enemy's movement speed in pixels per second.
@export var speed: float = 100.0

## The enemy's maximum health.
@export var max_health: float = 100.0

## How much gold the player gets for defeating this enemy.
@export var gold_reward: int = 10

## The name of the animation for moving up/away.
@export var animation_walk_up: StringName

## The name of the animation for moving down/towards.
@export var animation_walk_down: StringName
