extends Control
@onready var global = get_node("/root/Global")
@onready var Config = get_node("/root/ConfigFileHandler")
@onready var Fullscreen = $Fullscreen

# Called when the node enters the scene tree for the first time.
#func _ready():
	#var video_settings = ConfigFileHandler.load_video_settings()
	#Fullscreen.button_pressed = video_settings.fullscreen
	
func _ready():
	global.isgraphicsmenushowing = false
	if global.fullscreen == true:
		$Fullscreen.set_pressed(true)
		
	$Resolution.selected = global.selected_resolution

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if global.isgraphicsmenushowing == false:
		hide()
	elif global.isgraphicsmenushowing == true:
		show()
		
	if Input.is_action_just_pressed("ui_cancel"):
		if global.isgraphicsmenushowing == true:
			global.isgraphicsmenushowing = false
			global.ispausesettings_showing = true
		


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
			


			
func _on_fullscreen_toggled(toggled_on):
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		ConfigFileHandler.save_video_setting("fullscreen", toggled_on)
		global.fullscreen = true
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		global.fullscreen = false
		
		
	_save_settings(global.quality, global.fullscreen)
		
func _on_back_pressed():
	global.isgraphicsmenushowing = false
	global.ispausesettings_showing = true
	
	
# save the settings to a file
func _save_settings(quality, fullscreen):
	var file = FileAccess.open("user://video_settings.save", FileAccess.WRITE)
	if file:
		file.store_32(quality)
		file.store_line(str(fullscreen))
		file.close()
