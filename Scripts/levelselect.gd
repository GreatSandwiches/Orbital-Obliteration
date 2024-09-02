extends Control
@onready var global = get_node("/root/Global")




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_option_button_item_selected(index):
	match index:
		
		0: 
			global.selected_level = global.level_1
		
		1: 
			global.selected_level = global.level_2
		
		
			


func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/loadingscreen.tscn")


func _on_mode_select_toggled(button_pressed):
	if button_pressed == true:
		global.game_mode = 1
	
	else:
		global.game_mode = 0
		
