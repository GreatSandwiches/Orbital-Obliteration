extends Control
@onready var global = get_node("/root/Global")




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")



func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


func _on_singleplayer_pressed():
	global.game_mode = 0 
	get_tree().change_scene_to_file("res://Scenes/levelselect.tscn")
	


func _on_multiplayer_pressed():
	global.game_mode = 1 
	get_tree().change_scene_to_file("res://Scenes/levelselect.tscn") 
	
