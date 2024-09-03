extends Control
@onready var global = get_node("/root/Global")
@onready var menuparticles = get_node("/root/MenuParticles")


# Called when the node enters the scene tree for the first time.
func _ready():
	global.ismainmenu = true
	menuparticles.show() #ach this doesnt work yet


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")
	

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")
	

func _on_quit_pressed():
	get_tree().quit()



