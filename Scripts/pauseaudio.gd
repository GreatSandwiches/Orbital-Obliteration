extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/pausesettings.tscn")
	
	
func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, value/5)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/pausesettings.tscn")
