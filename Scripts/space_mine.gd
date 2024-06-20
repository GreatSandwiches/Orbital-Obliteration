extends Area2D

@onready var global = get_node("/root/Global")

func _ready():
	pass # Replace with function body.
func _process(delta):
	pass


func _player_collision(area):
	if area.is_in_group("player"):
		queue_free()
	if area.is_in_group("player1"):
		global.spacemine_collision_pos_p1 = position
		print(global.spacemine_collision_pos_p1)
