extends Area2D

@onready var global = get_node("/root/Global")
signal hit1

func _ready():
	pass
	
func _process(delta):
	pass

func _collision(area):
	if area.is_in_group("ast1"):
		global.wall_pos1 = position
		hit1.emit(self)

