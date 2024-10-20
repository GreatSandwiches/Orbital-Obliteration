extends Control

# Constants
const RESOLUTION_1152x648 = Vector2i(1152, 648)
const RESOLUTION_1920x1080 = Vector2i(1920, 1080)
const RESOLUTION_1280x720 = Vector2i(1280, 720)
const HIGH_QUALITY = 0
const MEDIUM_QUALITY = 1
const LOW_QUALITY = 2

# Variables
@onready var global = get_node("/root/Global")
@onready var Config = get_node("/root/ConfigFileHandler")
@onready var Fullscreen = $Fullscreen
@onready var current_scene = get_tree().current_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update the state of buttons and dropdowns
	if global.fullscreen:
		$Fullscreen.set_pressed(true)
		
	$Resolution.selected = global.selected_resolution
	$Quality.selected = global.quality


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# Function to set game resolution
func _on_resolution_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(RESOLUTION_1152x648)
			global.selected_resolution = 0
		1:
			DisplayServer.window_set_size(RESOLUTION_1920x1080)
			global.selected_resolution = 1
		2:
			DisplayServer.window_set_size(RESOLUTION_1280x720)
			global.selected_resolution = 2


# Go back to settings menu when back button is pressed
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")


# Save the quality setting to a file when the user selects a setting
func _on_quality_item_selected(index: int) -> void:
	match index:
		HIGH_QUALITY:
			get_viewport().msaa_2d = Viewport.MSAA_8X
			global.quality = HIGH_QUALITY
		MEDIUM_QUALITY:
			get_viewport().msaa_2d = Viewport.MSAA_2X
			global.quality = MEDIUM_QUALITY
		LOW_QUALITY:
			get_viewport().msaa_2d = Viewport.MSAA_DISABLED
			global.quality = LOW_QUALITY

	_save_settings(global.quality, global.fullscreen)


# Save the fullscreen setting when toggled
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		global.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		global.fullscreen = false

	_save_settings(global.quality, global.fullscreen)


# Save the settings to a file
func _save_settings(quality: int, fullscreen: bool) -> void:
	var file = FileAccess.open("user://video_settings.save", FileAccess.WRITE)
	if file:
		file.store_32(quality) # Store the quality setting
		file.store_line(str(fullscreen)) # Store the fullscreen value
		file.close()
	else:
		print("File not found")
