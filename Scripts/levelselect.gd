extends Control
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")


func _on_level_1_pressed():
	global.selected_level = global.level_1
	global.ismainmenu = false 
	get_tree().change_scene_to_file("res://Scenes/loadingscreen.tscn") 


func _on_level_2_pressed():
	global.selected_level = global.level_2
	global.ismainmenu = false 
	get_tree().change_scene_to_file("res://Scenes/loadingscreen.tscn")
	
