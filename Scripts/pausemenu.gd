extends Control
@onready var global = get_node("/root/Global")





''
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.ispausemenushowing == false:
		hide()
	elif global.ispausemenushowing == true:
		show()
		
	


func _on_options_pressed():
	global.ispausemenushowing = false
	#get_tree().change_scene_to_file("res://Scenes/pausesettings.tscn")
	global.ispausesettings_showing = true





func _on_quit_pressed():
	global.ispausemenushowing = false
	get_tree().paused = false
	global.paused = false
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


func _on_continue_pressed():
	global.ispausemenushowing = false
	hide()
	$GameTitle.hide()
	global.paused = false
	get_tree().paused = false
