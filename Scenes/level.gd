

extends Node2D

@onready var global = get_node("/root/Global")
@onready var camera = get_node("Camera2D")

func _ready():
	CameraLimits.set_limits(camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom)


func _process(delta):
	$P1_score.text = ("P1: " + str(global.p1_score))
