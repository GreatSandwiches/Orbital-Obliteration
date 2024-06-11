extends Line2D

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = Vector2(0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = Vector2(0,0)
	add_point(global.p1_location, -1)
