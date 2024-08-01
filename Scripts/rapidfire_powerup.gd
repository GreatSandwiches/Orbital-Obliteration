extends Area2D

@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D
@onready var respawn_timer = $RespawnTimer





# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _rapidfire_collect(area):
	if area.is_in_group("player"):
		print("pickedup")
		
		hitbox.set_deferred("disabled", true)
		hide()
		respawn_timer.start(10)



func _on_respawn_timer_timeout():
	hitbox.disabled = false
	show()
