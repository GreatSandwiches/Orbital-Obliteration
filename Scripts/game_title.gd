extends Label

@onready var global = get_node("/root/Global")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Shows title when the game is paused, hides it when the game is not paused
	if global.paused == false:
		hide()
	elif global.paused == true:
		show()
