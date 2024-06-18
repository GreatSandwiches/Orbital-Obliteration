extends Node2D

var paused = false





# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseMenu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Pause detection
	if Input.is_action_just_pressed("ui_cancel"):
		if paused == false:
			print("paused")
			paused = true
			get_tree().paused = true
			$PauseMenu.show()
		else:
			get_tree().paused = false
			print("unpaused")
			paused = false
			$PauseMenu.hide()
