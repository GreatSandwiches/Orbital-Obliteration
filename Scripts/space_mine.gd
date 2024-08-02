extends Area2D

@onready var global = get_node("/root/Global")
@onready var respawn_timer = $RespawnTimer
@onready var hitbox = $CollisionShape2D


signal p1_exploded
signal p2_exploded

func _ready():
	p1_exploded.connect(get_node("/root/Level/Player1")._mine_collision)
	p2_exploded.connect(get_node("/root/Level/Player2")._mine_collision)
	$AnimatedSprite2D.play()
	
func _process(delta):
	pass


func _player_collision(area):
	if area.is_in_group("player"):
		print(hitbox)
		hitbox.set_deferred("disabled", true)
		respawn_timer.start(8)
		#switchsprite here?/look to make greyed out.
		$HideTimer.start(2)
		
		
		
	if area.is_in_group("player1"):
		$GPUParticles2D.emitting = true
		global.spacemine_collision_pos_p1 = position
		print(global.spacemine_collision_pos_p1)
		p1_exploded.emit()
		
	if area.is_in_group("player2"):
		$GPUParticles2D.emitting = true
		global.spacemine_collision_pos_p2 = position
		print(global.spacemine_collision_pos_p2)
		p2_exploded.emit()


func _on_respawn_timer_timeout():
	$CollisionShape2D.disabled = false
	show()
	print("minerespawn")


func _on_hide_timer_timeout():
	hide()
