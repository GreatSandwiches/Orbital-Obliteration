

extends Node2D

@onready var global = get_node("/root/Global")
@onready var camera = get_node("Camera2D")

func _ready():
	CameraLimits.set_limits(camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom)


func _process(delta):
	$P2_Heat.value = global.p2_gunheat
	$P1_Heat.value = global.p1_gunheat
	$P1_Health.value = global.p1_health
	$P2_Health.value = global.p2_health
	$P1_score.text = ("P1: " + str(global.p1_score))
	$P2_score.text = ("P2: " + str(global.p2_score))
	
	if global.p1_score  == 3:
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
	
	elif global.p2_score == 3:
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
	
		
	
		
	
		
