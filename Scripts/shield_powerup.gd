extends Area2D

@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D
@onready var respawn_timer = $RespawnTimer
signal collect1
signal collect2
signal aicollect

func _ready():
	collect1.connect(get_node("/root/Level/Player1")._shield_powerup_collected)
	collect2.connect(get_node("/root/Level/Player2")._shield_powerup_collected)
	aicollect.connect(get_node("/root/Level/EnemyAi")._shield_powerup_collected)
	
func _process(delta):
	pass

func _collected(area):
	if area.is_in_group("player1"):
		collect1.emit()
		hitbox.set_deferred("disabled", true)
		hide()
		respawn_timer.start(10)
	if area.is_in_group("player2"):
		collect2.emit()
		hitbox.set_deferred("disabled", true)
		hide()
		respawn_timer.start(10)
	if area.is_in_group("ai"):
		aicollect.emit()
		hitbox.set_deferred("disabled", true)
		hide()
		respawn_timer.start(10)
		

func _duration_end():
	hitbox.disabled = false
	show()
