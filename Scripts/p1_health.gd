extends Node2D

@onready var global = get_node("/root/Global")
var pow_bar_value = 0

func _ready():
	pass
	
func _powered_up():
	pow_bar_value = 10
	$Powbartimer.start(1)
	

func _process(delta):
	if global.game_mode == 0:
		visible = false
	if $Powerup_bar.value > 0:
		$Powerup_bar.show()
	else:
		$Powerup_bar.hide()
	$Powerup_bar.value = pow_bar_value
	$P1_Healthbar.value = global.p1_health
	$P1_Heat.value = global.p1_gunheat
	position =  global.p1_position



func _powbartimer_tick_done():
	pow_bar_value -= 1
	if pow_bar_value > 0:
		$Powbartimer.start(1)
