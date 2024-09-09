extends Control
@onready var Config = get_node("/root/ConfigFileHandler")
@onready var Fullscreen = $Fullscreen

# Called when the node enters the scene tree for the first time.
#func _ready():
	#var video_settings = ConfigFileHandler.load_video_settings()
	#Fullscreen.button_pressed = video_settings.fullscreen
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/pausesettings.tscn")


func _on_resolution_item_selected(index):
	match index:
		
		0:
			DisplayServer.window_set_size(Vector2i(1152,648 ))
		1:
			DisplayServer.window_set_size(Vector2i(1920,1080 ))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720 ))
			
func _on_fullscreen_toggled(toggled_on):
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		ConfigFileHandler.save_video_setting("fullscreen", toggled_on)
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/pausesettings.tscn")
