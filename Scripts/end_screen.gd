extends Control
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _restart():
	get_tree().change_scene_to_file("res://Scenes/level.tscn")
	global.p1_score = 0
	global.p2_score = 0
