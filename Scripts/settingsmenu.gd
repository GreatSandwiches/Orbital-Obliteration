extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
	
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


func _on_audio_pressed():
	get_tree().change_scene_to_file("res://Scenes/audiomenu.tscn")


func _on_graphics_pressed():
	get_tree().change_scene_to_file("res://Scenes/graphicsmenu.tscn")
