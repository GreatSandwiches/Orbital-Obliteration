extends Line2D

@onready var global = get_node("/root/Global")

# Constants
const INITIAL_POSITION = Vector2(0, 0)
const MAX_POINTS = 10
const LOW_HEALTH_THRESHOLD = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Initialization can be added here if needed.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Reset the global position and add points to the line based on player 2's location
	global_position = INITIAL_POSITION
	add_point(global.p2_location, -1)

	# Remove the initial point if it matches the initial position
	if get_point_position(0) == INITIAL_POSITION:
		remove_point(0)

	# Keep the number of points within the defined maximum
	if get_point_count() > MAX_POINTS:
		remove_point(0)

	# Show or hide the smoke trail based on player 2's health
	if global.p2_health < LOW_HEALTH_THRESHOLD:
		hide()
	else:
		show()
