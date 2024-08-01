extends Line2D

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = Vector2(0,0)
	add_point(global.p2_location, -1)
	if get_point_position(0) == Vector2(0,0):
		remove_point(0)
	if get_point_count() > 10:
		remove_point(0)
		
	#Smoketrail
	if global.p2_health < 30:
		hide()
	else:
		show()
		

