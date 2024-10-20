extends Control

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Initialization code can be added here if needed.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle cancel action to return to the main menu
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Handles the back button press, returning to the main menu
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")


# Opens the audio settings menu
func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/audiomenu.tscn")


# Opens the graphics settings menu
func _on_graphics_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/graphicsmenu.tscn")
