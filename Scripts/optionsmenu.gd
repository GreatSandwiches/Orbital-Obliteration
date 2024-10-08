extends Control





func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, value/5)


func _on_mute_toggled(toggled_on):
	AudioServer.set_bus_mute(0,toggled_on)


func _on_resolution_item_selected(index):
	match index:
		
		0:
			DisplayServer.window_set_size(Vector2i(1152,648 ))
		1:
			DisplayServer.window_set_size(Vector2i(1920,1080 ))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720 ))


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


func _on_fullscreen_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	
