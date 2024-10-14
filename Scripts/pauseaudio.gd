extends Control
@onready var global = get_node("/root/Global")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Volume.value = global.volume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.isaudiomenushowing == false:
		hide()
	elif global.isaudiomenushowing == true:
		show()
	
	
	
func _on_volume_value_changed(value):
	global.volume = value
	AudioServer.set_bus_volume_db(0, value/5)


func _on_back_pressed():
	global.isaudiomenushowing = false
	global.ispausesettings_showing = true
	
