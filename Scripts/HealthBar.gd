extends ProgressBar

# Variables
@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health = 0 : set = _set_health


# Setter function to update health
func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health  # Update the main health bar value

	# Health decreased, start the timer to update the delayed damage bar
	if health <= prev_health:
		timer.start()
	
	# Health increased, immediately update the damage bar
	else:
		damage_bar.value = health


# Function to initialize the health system
func _init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health


# Called when the timer times out, to update the damage bar to match the current health
func _on_timer_timeout():
	damage_bar.value = health
