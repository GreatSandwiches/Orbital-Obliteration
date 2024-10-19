extends Control

# Variables
@onready var global = get_node("/root/Global")
@onready var Config = get_node("/root/ConfigFileHandler")
@onready var Fullscreen = $Fullscreen
@onready var current_scene = get_tree().current_scene
const HIGH_QUALITY = 0
const MEDIUM_QUALITY = 1
const LOW_QUALITY = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Updating state of buttons/dropdowns
	if global.fullscreen == true:
		$Fullscreen.set_pressed(true)
		
	$Resolution.selected = global.selected_resolution
	$Quality.selected = global.quality
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	
# Function to set game resolution	
func _on_resolution_item_selected(index):
	match index:
		
		0:
			DisplayServer.window_set_size(Vector2i(1152,648 ))
			global.selected_resolution = 0
		1:
			DisplayServer.window_set_size(Vector2i(1920,1080 ))
			global.selected_resolution = 1
		2:
			DisplayServer.window_set_size(Vector2i(1280,720 ))
			global.selected_resolution = 2
			

# Go back to menu when back button pressed
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")


# Save the quality setting to a file when the user selects a setting
func _on_quality_item_selected(index):
	match index:
		0:
			get_viewport().msaa_2d = Viewport.MSAA_8X
			global.quality = HIGH_QUALITY
		1:
			get_viewport().msaa_2d = Viewport.MSAA_2X
			global.quality = MEDIUM_QUALITY
		2:
			get_viewport().msaa_2d = Viewport.MSAA_DISABLED
			global.quality = LOW_QUALITY
	
	_save_settings(global.quality, global.fullscreen)


# Save the fullscreen setting when toggled
func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		global.fullscreen = true
		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		global.fullscreen = false
		
	_save_settings(global.quality, global.fullscreen)


# Save the settings to a file
func _save_settings(quality, fullscreen):
	var file = FileAccess.open("user://video_settings.save", FileAccess.WRITE)
	if file:
		file.store_32(quality) # Store the quality setting	
		file.store_line(str(fullscreen)) # Store the fullscreen value
		file.close()
	else: 
		print("File not found")

