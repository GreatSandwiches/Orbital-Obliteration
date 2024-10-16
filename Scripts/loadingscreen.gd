extends Control

# Variables
@onready var global = get_node("/root/Global")
@export var loading_bar : ProgressBar
@export var percentage_label : Label
var scene_path : String
var progress : Array
var update : float = 0.0
const SMOOTHNESS = 0.2
const LOADED = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	scene_path = global.selected_level
	ResourceLoader.load_threaded_request(scene_path) # Begin loading
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ResourceLoader.load_threaded_get_status(scene_path, progress) # Updating loading status
	
	if progress[0] > update:
		update = progress[0]
	
	# Detecting when finished loading - loads into level
	if loading_bar.value >= LOADED:
		if update >= LOADED:
			global.ismainmenu = false
			get_tree().change_scene_to_packed(
				ResourceLoader.load_threaded_get(scene_path)
			)
			
	# Updates the loading bar if it's value is less than the current update
	if loading_bar.value < update:
		loading_bar.value = lerp(loading_bar.value, update, delta)
	
	# Smoothing the progress of the loading bar
	loading_bar.value += delta * SMOOTHNESS * \
	 	(0.5 if update >= LOADED else clamp(0.9 - loading_bar.value, 0.0, 1.0))
	
	# Updating the percentage indicator label, converting to a percentage
	percentage_label.text = str(int(update * 100.0)) + " %"
	
	
	
	
