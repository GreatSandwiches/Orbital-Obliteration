extends Control

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize to hide the pause settings menu
	global.is_pause_settings_showing = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Handle cancel action to return to the pause menu
	if Input.is_action_just_pressed("ui_cancel"):
		if global.is_pause_settings_showing == true:
			global.is_pause_settings_showing = false
			global.is_pause_menu_showing = true

	# Show or hide the pause settings menu based on the global state
	if global.is_pause_settings_showing == false:
		hide()
	elif global.is_pause_settings_showing == true:
		show()


# Handles the back button press, returning to the pause menu
func _on_back_pressed() -> void:
	global.is_pause_settings_showing = false
	global.is_pause_menu_showing = true


# Opens the audio settings menu and hides the pause settings menu
func _on_audio_pressed() -> void:
	global.is_audio_menu_showing = true
	global.is_pause_settings_showing = false


# Opens the graphics settings menu and hides the pause settings menu
func _on_graphics_pressed() -> void:
	global.is_graphics_menu_showing = true
	global.is_pause_settings_showing = false
