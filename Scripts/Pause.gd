extends Node2D

# Variables
@onready var global = get_node("/root/Global")
var paused = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseMenu.hide() # Hides pause menu when scene is initalised
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# When Escape key is pressed, If game is not paused, pause it. Otherwise, unpause it
	if Input.is_action_just_pressed("ui_cancel"):
		if global.paused == false: 
			print("paused")
			global.paused = true
			get_tree().paused = true
			$PauseMenu.show() # Show pause menu
			$GameTitle.show()
			global.ispausemenushowing = true
			
		elif global.ispausemenushowing == true:
			get_tree().paused = false
			print("unpaused")
			global.paused = false
			$PauseMenu.hide() # Hide pause menu
			$GameTitle.hide()
			global.ispausemenushowing = false
