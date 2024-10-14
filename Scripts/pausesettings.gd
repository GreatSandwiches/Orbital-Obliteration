extends Control
@onready var global = get_node("/root/Global")


# Called when the node enters the scene tree for the first time.
func _ready():
	global.ispausesettings_showing = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if global.ispausesettings_showing == true:
			global.ispausesettings_showing = false
			global.ispausemenushowing = true
		
		
	if global.ispausesettings_showing == false:
		hide()
	elif global.ispausesettings_showing == true:
		show()
		
			
	
	
func _on_back_pressed():
	global.ispausesettings_showing = false
	global.ispausemenushowing = true


func _on_audio_pressed():
	#get_tree().change_scene_to_file("res://Scenes/pauseaudio.tscn")
	global.isaudiomenushowing = true
	global.ispausesettings_showing = false
	


func _on_graphics_pressed():
	#get_tree().change_scene_to_file("res://Scenes/pausegraphics.tscn")
	global.isgraphicsmenushowing = true
	global.ispausesettings_showing = false
