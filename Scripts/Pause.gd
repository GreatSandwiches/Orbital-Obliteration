extends Node2D

# Variables
@onready var global = get_node("/root/Global")
var paused = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseMenu.hide() # Hides pause menu when scene is initialized


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# When Escape key is pressed, if the game is not paused, pause it. Otherwise, unpause it
	if Input.is_action_just_pressed("ui_cancel"):
		if global.paused == false: 
			print("paused")
			global.paused = true
			get_tree().paused = true
			$PauseMenu.show() # Show pause menu
			$GameTitle.show()
			global.is_pause_menu_showing = true
			
		elif global.is_pause_menu_showing == true:
			get_tree().paused = false
			print("unpaused")
			global.paused = false
			$PauseMenu.hide() # Hide pause menu
			$GameTitle.hide()
			global.is_pause_menu_showing = false
