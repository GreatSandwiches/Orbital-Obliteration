

extends Node2D

@onready var camera = get_node("Camera2D")

func _ready():
	CameraLimits.set_limits(camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom)
