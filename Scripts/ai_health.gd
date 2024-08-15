extends Node2D

@onready var global = get_node("/root/Global")

func _ready():
	pass

func _process(delta):
	
	if global.game_mode == 1:
		visible = false
		
	$AI_Healthbar.value = global.ai_health
	#$P1_Heat.value = global.p1_gunheat
	position =  global.ai_position
