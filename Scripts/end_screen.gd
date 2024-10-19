extends Control
@onready var global = get_node("/root/Global")
const SINGLEPLAYER = 1
const MULTIPLAYER = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Begins emmitting particles when scene loads
	$CPUParticles2D.emitting = true
	$CPUParticles2D2.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handles what text will show on the end screen
	if global.p1_score > global.p2_score: # P1/AI wins
		if global.game_mode == SINGLEPLAYER:
			$Label2.text = "Player 1 wins!"
		elif  global.game_mode == MULTIPLAYER:
			$Label2.text = "AI wins!"
			
	elif global.p1_score < global.p2_score: # P2 wins
		if global.game_mode == SINGLEPLAYER:
			$Label2.text = "Player 2 wins!"
		elif  global.game_mode == MULTIPLAYER:
			$Label2.text = "You Win!"
			
		
# Function to handle the restarting of the game
func _restart():
	get_tree().change_scene_to_file(global.selected_level)
	
	# Resetting score
	global.p1_score = 0
	global.p2_score = 0

# Changes scene to menu when button pressed
func _menu():
	global.p1_score = 0
	global.p2_score = 0
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")

# Quits the game when "quit" button pressed
func _quit():
	get_tree().quit()
