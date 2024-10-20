extends Control

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Initialization code can be added here if needed.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Change to main menu scene if the cancel action is pressed.
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Handles the back button being pressed, returning to the main menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Starts the game in singleplayer mode and moves to the level select screen.
func _on_singleplayer_pressed() -> void:
	global.game_mode = 0
	get_tree().change_scene_to_file("res://Scenes/levelselect.tscn")


# Starts the game in multiplayer mode and moves to the level select screen.
func _on_multiplayer_pressed() -> void:
	global.game_mode = 1
	get_tree().change_scene_to_file("res://Scenes/levelselect.tscn")
