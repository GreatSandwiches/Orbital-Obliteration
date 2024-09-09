extends Control
@onready var master_volume_slider = $Volume

# Called when the node enters the scene tree for the first time.
#func _ready():
	#var audio_settings = ConfigFileHandler.load_audio_settings()
	#master_volume_slider.value = min(audio_settings.master_volume, 1.0) * 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")
	
	
func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, value/5)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")


func _on_volume_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_audio_setting("master_volume", master_volume_slider.value/100)
