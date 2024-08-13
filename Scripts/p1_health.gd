extends Node2D

@onready var global = get_node("/root/Global")

func _ready():
	pass

func _process(delta):
	$P1_Healthbar.value = global.p1_health
	$P1_Heat.value = global.p1_gunheat
	position =  global.p1_position
