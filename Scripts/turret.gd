extends Node2D

@export var bullet_scene: PackedScene
@onready var global = get_node("/root/Global")
var loaded = true
var target_position = Vector2(0, 0)
var direction = Vector2(0, 0)
var missile = 0
var angle_list = []
var reload_period = 0.5
var base_reload_period = 0.5
var increment = Vector2(1, 0)
var rotation_speed = PI / 70
var bullet_shotgun_angles = [(-2*PI/36), (-1*PI/36), 0, (1*PI/36), (2*PI/36)]
var missile_shotgun_angles = [(-2*PI/7), (-1*PI/7), 0, (1*PI/7), (2*PI/7)]


func _ready():
	# Makes the turret face to the right when spawning in
	target_position = position + increment
	direction = position + increment


func _shoot(deviation, type):
	# Fires the bullet
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	get_parent().add_child(bullet)


func _cooldown_done():
	loaded = true


func _process(_delta):
	if global.game_mode == 1:
		# Search for both players when game_mode is 1, target onto the closest one
		if (
				$Detection.overlaps_area(get_node("/root/Level/Player1").get_child(0)) 
				or $Detection.overlaps_area(get_node("/root/Level/Player2").get_child(0))
		):
			if position.distance_to(global.p1_position) <= position.distance_to(global.p2_position):
				target_position = global.p1_position
			else:
				target_position = global.p2_position
	if global.game_mode == 0:
		# Only look for Player 2 when game_mode is 0
		if $Detection.overlaps_area(get_node("/root/Level/Player2").get_child(0)):
			target_position = global.p2_position
	# Enables faster shooting when ai picks up rapid fire powerup
	if global.enemy_rapid == true:
		reload_period = base_reload_period / 2
	else:
		reload_period = base_reload_period
	# Calculate direction towards the target position
	direction = target_position - position
	# Rotate towards the target direction smoothly
	var angle = self.transform.x.angle_to(direction)
	self.rotate(sign(angle) * min(rotation_speed, abs(angle)))
	# Shooting logic
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			if loaded == true:
				if global.enemy_shotgun == true:
					# Setting an angle list for shotgun
					angle_list = bullet_shotgun_angles
					# Code for potentially shooting missiles (not implemented yet)
					if missile == 1:
						angle_list = missile_shotgun_angles
					# Cycles through an angle list to shoot 5 bullets with spread for shotgun	
					for deviation in angle_list:
						# Old random number generation code
						#var rng = RandomNumberGenerator.new()
						#global.p1_bulletspeed = 1 + rng.randf_range(-0.2, 0)
						if missile == 1:
							_shoot(deviation, "missile")
						else:
							_shoot(deviation, "bullet")
				else:
					# Shooting regular no spread bullets when shotgun inactive
					if missile == 1:
						_shoot(0, "missile")
					else:
						_shoot(0, "bullet")
				# Initiates shooting cooldown
				loaded = false
				$Timer.start(reload_period)
