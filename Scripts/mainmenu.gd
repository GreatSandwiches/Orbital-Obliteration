extends Control
@onready var global = get_node("/root/Global")
@onready var menuparticles = get_node("/root/MenuParticles")
@onready var mute_button: Button = $MuteButton
var low_quality = 2
var medium_quality = 1
var high_quality = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	global.ismainmenu = true
	menuparticles.show() 
	mute_button.text = "Mute"
	
	# Checking if settings are loaded or not
	if global.settings_loaded == false:
		_load_settings()
		global.settings_loaded = true
	
	# Checking the state of the "mute" button when loading
	if global.is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		mute_button.text = "Unmute" 
		mute_button.icon = load("res://Assets/icons8-mute-button-48.png")
	else:
		mute_button.icon = load("res://Assets/icons8-audio-48.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		mute_button.text = "Mute"
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# Changes scene to the mode select screen
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")
	
	
# Opens options menu when button pressed
func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")
	
	
# Quits the game when button pressed
func _on_quit_pressed():
	get_tree().quit()


# Function handling the different states of the mute button
func _on_mute_button_pressed():
	global.is_muted = !global.is_muted  # Toggle mute state
	if global.is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		mute_button.text = "Unmute" 
		mute_button.icon = load("res://Assets/icons8-mute-button-48.png")
	else:
		mute_button.icon = load("res://Assets/icons8-audio-48.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		mute_button.text = "Mute"
		
				
# Loads the graphics settings from a file when the project starts
func _load_settings():
	var file = FileAccess.open("user://video_settings.save", FileAccess.READ)
	if file:  # Checks if the file exists
		var quality = file.get_32()
		var fullscreen_str = file.get_line()
		file.close()
		
		# Convert the fullscreen string to bool
		var fullscreen = fullscreen_str == "true"

		# Set the MSAA based on the saved quality
		match quality:
			0:
				get_viewport().msaa_2d = Viewport.MSAA_8X # High quality
				global.quality = high_quality
			1:
				get_viewport().msaa_2d = Viewport.MSAA_2X # Medium quality
				global.quality = medium_quality
			2:
				get_viewport().msaa_2d = Viewport.MSAA_DISABLED # Low quality
				global.quality = low_quality
	
		# Set the fullscreen mode based on the saved value
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			global.fullscreen = true
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			global.fullscreen = false
			
	else: # Settings will be reset to default if no file is found
		print("Failure fetching file")
			
	# Loads the audio settings from a file when the game starts	
	if FileAccess.file_exists("user://audio_settings.save"):
		
		var audiofile = FileAccess.open("user://audio_settings.save", FileAccess.READ)
		if audiofile:  # Check if the file exists
			var volume = audiofile.get_var() # Accessing file
			print(volume)
			audiofile.close()
		
			AudioServer.set_bus_volume_db(0, volume/5) # Setting the game volume
			global.volume = volume
	else: 
		print("audio file does not exist")
