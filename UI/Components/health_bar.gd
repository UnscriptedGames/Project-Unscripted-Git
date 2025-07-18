extends TextureProgressBar

## Updates the bar's visual based on current and max health.
func update_health(current_health: float, max_health: float) -> void:
	# Set the bar's range and current value.
	max_value = max_health
	value = current_health
