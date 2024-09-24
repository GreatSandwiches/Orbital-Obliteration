extends Control
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	$CPUParticles2D.emitting = true
	$CPUParticles2D2.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.p1_score > global.p2_score:
		if global.game_mode == 1:
			$Label2.text = "Player 1 wins!"
		elif  global.game_mode == 0:
			$Label2.text = "AI wins!"
	elif global.p1_score < global.p2_score:
		if global.game_mode == 1:
			$Label2.text = "Player 2 wins!"
		elif  global.game_mode == 0:
			$Label2.text = "You Win!"
			
		

func _restart():
	get_tree().change_scene_to_file(global.selected_level)
	global.p1_score = 0
	global.p2_score = 0


func _menu():
	global.p1_score = 0
	global.p2_score = 0
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


func _quit():
	get_tree().quit()
