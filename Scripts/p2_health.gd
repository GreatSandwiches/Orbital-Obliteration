extends Node2D

@onready var global = get_node("/root/Global")
var pow_bar_value = 0

func _ready():
	pass
	
func _powered_up():
	pow_bar_value = 10
	$Powbartimer.start(1)

func _process(delta):
	$Powerup_bar.value = pow_bar_value
	$P2_Healthbar.value = global.p2_health
	$P2_Heat.value = global.p2_gunheat
	position =  global.p2_position
	
func _powbartimer_tick_done():
	pow_bar_value -= 1
	if pow_bar_value > 0:
		$Powbartimer.start(1)
