extends Control
@onready var global = get_node("/root/Global")
@onready var menuparticles = get_node("/root/MenuParticles")
@onready var mute_button: Button = $MuteButton


# Called when the node enters the scene tree for the first time.
func _ready():
	global.ismainmenu = true
	menuparticles.show() #ach this doesnt work yet
	mute_button.text = "Mute"
	
	if global.settings_loaded == false:
		_load_settings()
		global.settings_loaded = true
	
	
	
	if global.is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		mute_button.text = "Unmute" 
		mute_button.icon = load("res://Assets/icons8-mute-button-48.png")
	else:
		mute_button.icon = load("res://Assets/icons8-audio-48.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		mute_button.text = "Mute"
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")
	

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")
	

func _on_quit_pressed():
	get_tree().quit()



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
		
		
		
# load the settings from a file when the project starts
func _load_settings():
	var file = FileAccess.open("user://video_settings.save", FileAccess.READ)
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
			
		
	if FileAccess.file_exists("user://audio_settings.save"):
		
		var audiofile = FileAccess.open("user://audio_settings.save", FileAccess.READ)
		if audiofile != null:  # Check if the file exists
			var volume = audiofile.get_var()
			print(volume)
			audiofile.close()
			if volume != null:
				AudioServer.set_bus_volume_db(0, volume/5)
				global.volume = volume
	else: 
		print("audio file does not exist")
