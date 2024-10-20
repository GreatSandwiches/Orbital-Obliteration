extends Node2D

# Variables
@onready var global = get_node("/root/Global")
@onready var camera = get_node("Camera2D")
var max_score = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	global.is_pause_settings_showing = false
	
	# Defining camera limits
	CameraLimits.set_limits(camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom)


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	$P1_score.text = "P1: " + str(global.p1_score)
	$P2_score.text = "P2: " + str(global.p2_score)
	
	# Detecting when to end the game
	if global.p1_score == max_score or global.p2_score == max_score:
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
