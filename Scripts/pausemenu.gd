extends Control


func _on_close_button_pressed():
	hide()
	get_tree().paused = false


''
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_options_pressed():
	hide()
	
	get_tree().change_scene_to_file("res://Scenes/pausesettings.tscn")





func _on_quit_pressed():
	hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
