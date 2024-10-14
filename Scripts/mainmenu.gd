extends Control
@onready var global = get_node("/root/Global")
@onready var menuparticles = get_node("/root/MenuParticles")
@onready var mute_button: Button = $MuteButton



# Called when the node enters the scene tree for the first time.
func _ready():
	global.ismainmenu = true
	menuparticles.show() #ach this doesnt work yet
	mute_button.text = "Mute"
	
	if global.is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		mute_button.text = "Unmute" 
		mute_button.icon = load("res://Assets/icons8-mute-button-48.png")
	else:
		mute_button.icon = load("res://Assets/icons8-audio-48.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		mute_button.text = "Mute"
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/modeselect.tscn")
	

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/settingsmenu.tscn")
	

func _on_quit_pressed():
	get_tree().quit()



func _on_mute_button_pressed():
	global.is_muted = !global.is_muted  # Toggle mute state
	if global.is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		mute_button.text = "Unmute" 
		mute_button.icon = load("res://Assets/icons8-mute-button-48.png")
	else:
		mute_button.icon = load("res://Assets/icons8-audio-48.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		mute_button.text = "Mute"
