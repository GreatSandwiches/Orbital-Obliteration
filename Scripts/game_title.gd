extends Label
@onready var global = get_node("/root/Global")


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.paused == false:
		hide()
	elif global.paused == true:
		show()
		
