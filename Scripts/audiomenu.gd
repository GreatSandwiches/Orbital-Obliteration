extends Control

@onready var master_volume_slider = $Volume
@onready var global = get_node("/root/Global")

const VOLUME_DIVISOR: float = 5.0
const AUDIO_SETTINGS_PATH: String = "user://audio_settings.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Volume.value = global.volume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Return to settings menu if the cancel action is pressed.
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")


# Triggered when the volume slider value is changed.
func _on_volume_value_changed(value: float) -> void:
	global.volume = value
	AudioServer.set_bus_volume_db(0, value / VOLUME_DIVISOR)
	_save_settings(global.volume)


# Triggered when the back button is pressed.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")


# Saves the current volume setting to a file.
func _save_settings(volume: float) -> void:
	var file = FileAccess.open(AUDIO_SETTINGS_PATH, FileAccess.WRITE)
	if file:
		print("Saving volume:", volume)
		file.store_var(volume)
		file.close()
	else:
		print("Failed to open file for writing")
