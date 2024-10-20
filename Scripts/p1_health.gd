extends Node2D

@onready var global = get_node("/root/Global")
@onready var pow_bar_timer = $Powbartimer
@onready var powerup_bar = $Powerup_bar
@onready var p1_healthbar = $P1_Healthbar
@onready var p1_heat = $P1_Heat

var pow_bar_value: int = 0

const POW_BAR_INITIAL_VALUE: int = 10
const POW_BAR_TIMER_INTERVAL: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Handles the powered-up state, initializing the power bar.
func _powered_up() -> void:
	pow_bar_value = POW_BAR_INITIAL_VALUE
	pow_bar_timer.start(POW_BAR_TIMER_INTERVAL)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Hide the node if the game mode is 0.
	if global.game_mode == 0:
		visible = false

	# Show or hide the power-up bar based on its value.
	if powerup_bar.value > 0:
		powerup_bar.show()
	else:
		powerup_bar.hide()

	# Update UI elements based on global state and power bar value.
	powerup_bar.value = pow_bar_value
	p1_healthbar.value = global.p1_health
	p1_heat.value = global.p1_gun_heat
	position = global.p1_position


# Decrease the power bar value and restart the timer if needed.
func _pow_bar_timer_tick_done() -> void:
	pow_bar_value -= 1
	if pow_bar_value > 0:
		pow_bar_timer.start(POW_BAR_TIMER_INTERVAL)
