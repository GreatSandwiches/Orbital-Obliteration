extends Control
@onready var master_volume_slider = $Volume
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Volume.value = global.volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")
	
	
func _on_volume_value_changed(value):
	global.volume = value
	AudioServer.set_bus_volume_db(0, value/5)
	
	_save_settings(global.volume)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")

		


func _save_settings(volume):
	var file = FileAccess.open("user://audio_settings.save", FileAccess.WRITE)
	if file:
		print("Saving volume:", volume)
		file.store_var(volume)
		file.close()
	else:
		print("Failed to open file for writing")
