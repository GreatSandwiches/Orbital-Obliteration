extends Control

@onready var global = get_node("/root/Global")
@onready var fullscreen_button = $Fullscreen

# Constants
const RESOLUTION_1152x648 = Vector2i(1152, 648)
const RESOLUTION_1920x1080 = Vector2i(1920, 1080)
const RESOLUTION_1280x720 = Vector2i(1280, 720)
const VIDEO_SETTINGS_FILE_PATH = "user://video_settings.save"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.is_graphics_menu_showing = false

	# Set fullscreen button state based on global settings
	if global.fullscreen == true:
		fullscreen_button.set_pressed(true)

	# Set the resolution selector to the current resolution
	$Resolution.selected = global.selected_resolution


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Show or hide the graphics menu based on the global state
	if global.is_graphics_menu_showing == false:
		hide()
	elif global.is_graphics_menu_showing == true:
		show()

	# Handle cancel action to switch between menu states
	if Input.is_action_just_pressed("ui_cancel"):
		if global.is_graphics_menu_showing == true:
			global.is_graphics_menu_showing = false
			global.is_pause_settings_showing = true


# Adjusts the resolution based on the selected index
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


# Toggles fullscreen mode based on button state
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		global.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		global.fullscreen = false

	# Save settings whenever the fullscreen mode is changed
	_save_settings(global.quality, global.fullscreen)


# Handles the back button press, returning to the pause settings menu
func _on_back_pressed() -> void:
	global.is_graphics_menu_showing = false
	global.is_pause_settings_showing = true


# Saves the video settings to a file
func _save_settings(quality: int, fullscreen: bool) -> void:
	var file = FileAccess.open(VIDEO_SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(quality)
		file.store_line(str(fullscreen))
		file.close()
