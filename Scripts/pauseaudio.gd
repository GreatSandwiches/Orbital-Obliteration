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
		
	if Input.is_action_just_pressed("ui_cancel"):
		if global.isaudiomenushowing == true:
			global.isaudiomenushowing = false
			global.ispausesettings_showing = true
			
	
	
	
func _on_volume_value_changed(value):
	global.volume = value
	AudioServer.set_bus_volume_db(0, value/5)


func _on_back_pressed():
	global.isaudiomenushowing = false
	global.ispausesettings_showing = true
	
