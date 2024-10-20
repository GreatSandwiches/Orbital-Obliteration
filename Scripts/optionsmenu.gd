extends Control

# Constants for resolution settings
const RESOLUTION_1152x648 = Vector2i(1152, 648)
const RESOLUTION_1920x1080 = Vector2i(1920, 1080)
const RESOLUTION_1280x720 = Vector2i(1280, 720)
const AUDIO_BUS_INDEX = 0
const VOLUME_DIVISOR = 5

# Handles the back button press, returning to the main menu
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Adjusts the audio volume based on the slider value
func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS_INDEX, value / VOLUME_DIVISOR)


# Toggles the mute setting for the audio
func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AUDIO_BUS_INDEX, toggled_on)


# Changes the window resolution based on the selected index
func _on_resolution_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(RESOLUTION_1152x648)
		1:
			DisplayServer.window_set_size(RESOLUTION_1920x1080)
		2:
			DisplayServer.window_set_size(RESOLUTION_1280x720)


# Handles an additional back button press, returning to the main menu
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Toggles the fullscreen mode based on button press
func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
