extends Area2D

@onready var global = get_node("/root/Global")

signal p1_exploded
signal p2_exploded

func _ready():
	p1_exploded.connect(get_node("/root/Node2D2/Player1")._mine_collision)
	p2_exploded.connect(get_node("/root/Node2D2/Player2")._mine_collision)
func _process(delta):
	pass


func _player_collision(area):
	if area.is_in_group("player"):
		queue_free()
		
	if area.is_in_group("player1"):
		global.spacemine_collision_pos_p1 = position
		print(global.spacemine_collision_pos_p1)
		p1_exploded.emit()
		
	if area.is_in_group("player2"):
		global.spacemine_collision_pos_p2 = position
		print(global.spacemine_collision_pos_p2)
		p2_exploded.emit()
