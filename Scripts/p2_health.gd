extends Node2D

@onready var global = get_node("/root/Global")

func _ready():
	pass

func _process(delta):
	$P2_Healthbar.value = global.p2_health
	$P2_Heat.value = global.p2_gunheat
	position =  global.p2_position
