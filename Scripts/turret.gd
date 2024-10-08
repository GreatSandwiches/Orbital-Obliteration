extends Node2D


@export var bullet_scene: PackedScene
@onready var global = get_node("/root/Global")
var loaded = true
var target_position = Vector2(0,0)
var direction = Vector2(0,0)
var missile = 0
var angle_list = []
var reload_period = 0.5

func _ready():
	target_position = position + Vector2(1,0)
	direction = position + Vector2(1,0)

func _shoot(deviation, type):
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	get_parent().add_child(bullet)

func _cooldown_done():
	loaded = true

func _process(delta):
	if global.game_mode == 1:
		# Search for both players when game_mode is 1
		if $Detection.overlaps_area(get_node("/root/Level/Player1").get_child(0)) or $Detection.overlaps_area(get_node("/root/Level/Player2").get_child(0)):
			if position.distance_to(global.p1_position) <= position.distance_to(global.p2_position):
				target_position = global.p1_position
			else:
				target_position = global.p2_position
	if global.game_mode == 0:
		# Only look for Player 2 when game_mode is 0
		if $Detection.overlaps_area(get_node("/root/Level/Player2").get_child(0)):
			target_position = global.p2_position
	
	if global.enemy_rapid == true:
		reload_period = 0.2
	else:
		reload_period = 0.5
	
	# Calculate direction towards the target position
	direction = target_position - position
	
	# Rotate towards the target direction smoothly
	var angle = self.transform.x.angle_to(direction)
	self.rotate(sign(angle) * min(PI / 70, abs(angle)))

	# Shooting logic
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			if loaded == true:
				if global.enemy_shotgun == true:
					angle_list = [(-2*PI/36), (-1*PI/36), 0, (1*PI/36), (2*PI/36)]
					if missile == 1:
						angle_list = [(-2*PI/7), (-1*PI/7), 0, (1*PI/7), (2*PI/7)]
					for deviation in angle_list:
						#var rng = RandomNumberGenerator.new()
						#global.p1_bulletspeed = 1 + rng.randf_range(-0.2, 0)
						if missile == 1:
							_shoot(deviation, "missile")
							global.p1_gunheat += 2
						else:
							_shoot(deviation, "bullet")
							global.p1_gunheat += 0.1
				else:	
					if missile == 1:
						_shoot(0, "missile")
					else:
						_shoot(0, "bullet")
				loaded = false
				$Timer.start(reload_period)
