extends Area2D
func _process(delta: float) -> void:
	position.x += 100 * delta


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
