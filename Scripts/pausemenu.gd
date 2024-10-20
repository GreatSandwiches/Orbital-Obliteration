extends Control

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Initialization code can be added here if needed.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Show or hide the pause menu based on the global state
	if global.is_pause_menu_showing == false:
		hide()
	elif global.is_pause_menu_showing == true:
		show()


# Handles the options button press, opening the pause settings menu
func _on_options_pressed() -> void:
	global.is_pause_menu_showing = false
	global.is_pause_settings_showing = true


# Handles the quit button press, returning to the main menu and unpausing the game
func _on_quit_pressed() -> void:
	global.is_pause_menu_showing = false
	get_tree().paused = false
	global.paused = false
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Handles the continue button press, hiding the pause menu and resuming the game
func _on_continue_pressed() -> void:
	global.is_pause_menu_showing = false
	hide()
	$GameTitle.hide()
	global.paused = false
	get_tree().paused = false
