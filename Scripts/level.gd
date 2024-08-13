extends Node2D

@onready var global = get_node("/root/Global")
@onready var camera = get_node("Camera2D")

var paused = false

func _ready():
	
	CameraLimits.set_limits(camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom)

func _process(delta):
	$P1_score.text = ("P1: " + str(global.p1_score))
	$P2_score.text = ("P2: " + str(global.p2_score))

	if global.p1_score == 3 or global.p2_score == 3:
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")

	
			
	
