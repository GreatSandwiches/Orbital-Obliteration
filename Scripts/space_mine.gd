extends Area2D

func _ready():
	pass # Replace with function body.
func _process(delta):
	pass


func _player_collision(area):
	if area.is_in_group("player"):
		queue_free()
		