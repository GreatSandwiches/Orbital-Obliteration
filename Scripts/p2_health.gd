extends Node2D

@onready var global = get_node("/root/Global")

# Constants
const POW_BAR_INITIAL_VALUE = 10
const POW_BAR_TIMER_INTERVAL = 1

# Variables
var pow_bar_value = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Initialization code can be added here if needed


# Handles the logic when the power-up is activated
func _powered_up() -> void:
	pow_bar_value = POW_BAR_INITIAL_VALUE
	$Powbartimer.start(POW_BAR_TIMER_INTERVAL)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Show or hide the power-up bar based on its value
	if $Powerup_bar.value > 0:
		$Powerup_bar.show()
	else:
		$Powerup_bar.hide()
	
	# Update UI elements based on global state and power bar value
	$Powerup_bar.value = pow_bar_value
	$P2_Healthbar.value = global.p2_health
	$P2_Heat.value = global.p2_gun_heat
	position = global.p2_position


# Reduces the power bar value and restarts the timer if necessary
func _pow_bar_timer_tick_done() -> void:
	pow_bar_value -= 1
	if pow_bar_value > 0:
		$Powbartimer.start(POW_BAR_TIMER_INTERVAL)
