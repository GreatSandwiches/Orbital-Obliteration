extends Control
@onready var global = get_node("/root/Global")

@export var loading_bar : ProgressBar
@export var percentage_label : Label

var scene_path : String
var progress : Array
var update : float = 0.0

func _ready():
	scene_path = global.selected_level
	ResourceLoader.load_threaded_request(scene_path)
	

func _process(delta):
	ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	if progress[0] > update:
		update = progress[0]
		
		
	
	if loading_bar.value >= 1.0:
		if update >= 1.0:
			get_tree().change_scene_to_packed(
				ResourceLoader.load_threaded_get(scene_path)
			)
	if loading_bar.value < update:
		loading_bar.value = lerp(loading_bar.value, update, delta)
		
	
	loading_bar.value += delta * 0.2 * \
	 	(0.5 if update >= 1.0 else clamp(0.9 - loading_bar.value, 0.0, 1.0))
		
	percentage_label.text = str(int(update * 100.0)) + " %"
	
	
	
	
