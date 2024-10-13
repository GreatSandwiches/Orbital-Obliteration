extends Node2D
@onready var global = get_node("/root/Global")
var paused = false





# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseMenu.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Pause detection
	if Input.is_action_just_pressed("ui_cancel"):
		if global.paused == false:
			print("paused")
			global.paused = true
			get_tree().paused = true
			$PauseMenu.show()
			$GameTitle.show()
			global.ispausemenushowing = true
			
		else:
			get_tree().paused = false
			print("unpaused")
			global.paused = false
			$PauseMenu.hide()
			$GameTitle.hide()
			global.ispausemenushowing = false
