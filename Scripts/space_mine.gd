extends Area2D

@onready var global = get_node("/root/Global")
@onready var respawn_timer = $RespawnTimer
@onready var hitbox = $CollisionShape2D

var respawn_delay = 8

signal p1_exploded
signal p2_exploded
signal ai_exploded


func _ready():
	# Setting up signal connections
	p1_exploded.connect(get_node("/root/Level/Player1")._mine_collision)
	p2_exploded.connect(get_node("/root/Level/Player2")._mine_collision)
	ai_exploded.connect(get_node("/root/Level/EnemyAi")._mine_collision)
	$AnimatedSprite2D.play()


func _process(_delta):
	pass


func _player_collision(area):
	# Deletes spacemine when players/ai/projectiles hit it
	if (
			area.is_in_group("player") 
			or area.is_in_group("bullet") 
			or area.is_in_group("missile") 
			or area.is_in_group("ai")
	):
		hitbox.set_deferred("disabled", true)
		$GPUParticles2D.emitting = true
		$AnimatedSprite2D.hide()
		respawn_timer.start(respawn_delay)
	
	# Emits damage signal when players/ai hit it
	if area.is_in_group("player1"):
		global.spacemine_collision_pos_p1 = position
		p1_exploded.emit()
	if area.is_in_group("player2"):
		global.spacemine_collision_pos_p2 = position
		p2_exploded.emit()
	if area.is_in_group("ai"):
		global.spacemine_collision_pos_p1 = position
		ai_exploded.emit()


func _on_respawn_timer_timeout():
	# Makes spacemine reappear after certain period
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.show()
	print("minerespawn")
