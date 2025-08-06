extends Control

# Constants
const SINGLEPLAYER = 1
const MULTIPLAYER = 0

# Variables
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Begin emitting particles when the scene loads
	$CPUParticles2D.emitting = true
	$CPUParticles2D2.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handles what text will show on the end screen
	if global.ai_permanently_defeated and global.game_mode == 0:
		# Special case: AI was permanently defeated
		$Label2.text = "You Win! AI Defeated!"
	elif global.p1_score > global.p2_score: # P1/AI wins
		if global.game_mode == 0:  # Fixed: was SINGLEPLAYER (1), should be 0
			$Label2.text = "AI wins!"
		elif global.game_mode == 1:  # Fixed: was MULTIPLAYER (0), should be 1
			$Label2.text = "Player 1 wins!"
			
	elif global.p1_score < global.p2_score: # P2 wins
		if global.game_mode == 0:  # Fixed: was SINGLEPLAYER (1), should be 0
			$Label2.text = "You Win!"
		elif global.game_mode == 1:  # Fixed: was MULTIPLAYER (0), should be 1
			$Label2.text = "Player 2 wins!"


# Function to handle the restarting of the game
func _restart() -> void:
	get_tree().change_scene_to_file(global.selected_level)
	
	# Resetting score and AI state
	global.p1_score = 0
	global.p2_score = 0
	global.ai_permanently_defeated = false


# Changes scene to menu when button pressed
func _menu() -> void:
	global.p1_score = 0
	global.p2_score = 0
	global.ai_permanently_defeated = false
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Quits the game when "quit" button is pressed
func _quit() -> void:
	get_tree().quit()
