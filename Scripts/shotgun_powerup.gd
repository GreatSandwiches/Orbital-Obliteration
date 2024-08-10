extends Area2D

@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D
@onready var respawn_timer = $RespawnTimer
signal collect

func _ready():
	collect.connect(get_node("/root/Level/Player1")._shotgun_powerup_collected)
	
func _process(delta):
	pass

func _collected(area):
	if area.is_in_group("player"):
		collect.emit()
		hitbox.set_deferred("disabled", true)
		hide()
		respawn_timer.start(10)

func _duration_end():
	hitbox.disabled = false
	show()
