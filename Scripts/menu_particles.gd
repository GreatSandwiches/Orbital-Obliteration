extends GPUParticles2D

# Variables
@onready var global = get_node("/root/Global")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	 # Emits particles when game is in main menu state
	if global.ismainmenu == true:
		emitting = true
		show()
	else:
		emitting = false
		hide()
	
