extends Control

# Variables
@onready var global = get_node("/root/Global")
@export var loading_bar: ProgressBar
@export var percentage_label: Label
var scene_path: String
var progress: Array
var update: float = 0.0

# Constants
const SMOOTHNESS = 0.2
const LOADED = 1.0
const FULL_PERCENTAGE = 100.0
const HALF_PROGRESS = 0.5
const MAX_PROGRESS_BEFORE_LOAD = 0.9
const ZERO_VALUE = 0.0
const MINIMUM_PROGRESS = 0.0
const MAXIMUM_PROGRESS = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	scene_path = global.selected_level
	ResourceLoader.load_threaded_request(scene_path)  # Begin loading


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(scene_path, progress)  # Updating loading status

	if progress[0] > update:
		update = progress[0]

	# Detecting when finished loading, When finished, loads into level.
	if loading_bar.value >= LOADED and update >= LOADED:
		global.is_main_menu = false
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(scene_path) # Changing scene to level
		)

	# Updates the loading bar if its value is less than the current update
	if loading_bar.value < update:
		loading_bar.value = lerp(loading_bar.value, update, delta)

	# Smoothing the visual progress of the loading bar
	loading_bar.value += delta * SMOOTHNESS * (
		HALF_PROGRESS if update >= LOADED else clamp(MAX_PROGRESS_BEFORE_LOAD - loading_bar.value,
		 MINIMUM_PROGRESS, MAXIMUM_PROGRESS)
	)

	# Updating the percentage indicator label, converting to a percentage
	percentage_label.text = str(int(update * FULL_PERCENTAGE)) + " %"
