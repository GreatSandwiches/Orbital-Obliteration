extends Control

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Initialization code can be added here if needed.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Change to mode select scene if the cancel action is pressed.
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")


# Triggered when the back button is pressed.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")


# Triggered when the level 1 button is pressed.
func _on_level_1_pressed() -> void:
	global.selected_level = global.level_1
	get_tree().change_scene_to_file("res://Scenes/loadingscreen.tscn")


# Triggered when the level 2 button is pressed.
func _on_level_2_pressed() -> void:
	global.selected_level = global.level_2
	get_tree().change_scene_to_file("res://Scenes/loadingscreen.tscn")
