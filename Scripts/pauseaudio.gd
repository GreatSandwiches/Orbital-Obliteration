extends Control

@onready var global = get_node("/root/Global")

# Constants
const AUDIO_BUS_INDEX = 0
const VOLUME_DIVISOR = 5
const AUDIO_SETTINGS_FILE_PATH = "user://audio_settings.save"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the volume slider value based on the global volume setting
	$Volume.value = global.volume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Show or hide the audio menu based on the global state
	if global.is_audio_menu_showing == false:
		hide()
	elif global.is_audio_menu_showing == true:
		show()

	# Handle cancel action to switch between menu states
	if Input.is_action_just_pressed("ui_cancel"):
		if global.is_audio_menu_showing == true:
			global.is_audio_menu_showing = false
			global.is_pause_settings_showing = true


# Adjusts the audio volume when the slider value changes and saves the setting
func _on_volume_value_changed(value: float) -> void:
	global.volume = value
	AudioServer.set_bus_volume_db(AUDIO_BUS_INDEX, value / VOLUME_DIVISOR)
	_save_settings(global.volume)


# Handles the back button press, returning to the pause settings menu
func _on_back_pressed() -> void:
	global.is_audio_menu_showing = false
	global.is_pause_settings_showing = true


# Saves the current volume setting to a file
func _save_settings(volume: float) -> void:
	var file = FileAccess.open(AUDIO_SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		print("Saving volume:", volume)
		file.store_32(int(volume))
		file.close()
	else:
		print("Failed to open file for writing")
