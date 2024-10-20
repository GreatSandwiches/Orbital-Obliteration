extends Control

@onready var global = get_node("/root/Global")
@onready var menu_particles = get_node("/root/MenuParticles")
@onready var mute_button: Button = $MuteButton

# Constants
const AUDIO_BUS_NAME = "Master"
const MUTE_ICON_PATH = "res://Assets/icons8-mute-button-48.png"
const AUDIO_ICON_PATH = "res://Assets/icons8-audio-48.png"
const VIDEO_SETTINGS_FILE_PATH = "user://video_settings.save"
const AUDIO_SETTINGS_FILE_PATH = "user://audio_settings.save"
const VOLUME_DIVISOR = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.is_main_menu = true
	menu_particles.show() # Display menu particles (needs further setup to work)
	mute_button.text = "Mute"
	
	if global.settings_loaded == false:
		_load_settings()
		global.settings_loaded = true
	
	# Set mute button state based on global settings
	if global.is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(AUDIO_BUS_NAME), true)
		mute_button.text = "Unmute"
		mute_button.icon = load(MUTE_ICON_PATH)
	else:
		mute_button.icon = load(AUDIO_ICON_PATH)
		AudioServer.set_bus_mute(AudioServer.get_bus_index(AUDIO_BUS_NAME), false)
		mute_button.text = "Mute"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # No per-frame processing needed currently


# Handles the play button press, transitioning to mode select
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")


# Handles the options button press, transitioning to settings menu
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")


# Handles the quit button press, closing the application
func _on_quit_pressed() -> void:
	get_tree().quit()


# Toggles mute state when the mute button is pressed
func _on_mute_button_pressed() -> void:
	global.is_muted = !global.is_muted  # Toggle mute state
	if global.is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(AUDIO_BUS_NAME), true)
		mute_button.text = "Unmute"
		mute_button.icon = load(MUTE_ICON_PATH)
	else:
		mute_button.icon = load(AUDIO_ICON_PATH)
		AudioServer.set_bus_mute(AudioServer.get_bus_index(AUDIO_BUS_NAME), false)
		mute_button.text = "Mute"


# Loads settings from a file when the project starts
func _load_settings() -> void:
	var file = FileAccess.open(VIDEO_SETTINGS_FILE_PATH, FileAccess.READ)
	if file:  # Check if the file exists
		var quality = file.get_32()
		var fullscreen_str = file.get_line()
		file.close()
		
		# Convert the fullscreen string to bool
		var fullscreen = fullscreen_str == "true"

		# Set the MSAA based on the saved quality
		match quality:
			0:
				get_viewport().msaa_2d = Viewport.MSAA_8X
				global.quality = 0
			1:
				get_viewport().msaa_2d = Viewport.MSAA_2X
				global.quality = 1
			2:
				get_viewport().msaa_2d = Viewport.MSAA_DISABLED
				global.quality = 2

		# Set the fullscreen mode based on the saved value
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			global.fullscreen = true
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			global.fullscreen = false

	# Load audio settings if they exist
	if FileAccess.file_exists(AUDIO_SETTINGS_FILE_PATH):
		var audiofile = FileAccess.open(AUDIO_SETTINGS_FILE_PATH, FileAccess.READ)
		if audiofile != null:  # Check if the file exists
			var volume = audiofile.get_var()
			print(volume)
			audiofile.close()
			if volume != null:
				AudioServer.set_bus_volume_db(0, volume / VOLUME_DIVISOR)
				global.volume = volume
	else:
		print("Audio settings file does not exist")
