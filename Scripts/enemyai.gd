extends CharacterBody2D
@onready var global = get_node("/root/Global")
@export var bullet_scene: PackedScene
@export var missile_scene: PackedScene
var speed = 180
var accel = 2
var min_distance = 50
var loaded = true
var ko_scale
var reload_period = 0.5
var missile = 0
var angle_list = []
var knockback = Vector2(0,0)
var shield = true
var immunity = true
var projectile = null
var powerup_locations = []
var target = Vector2(0,0)
var target_check = 0
var missilepwrlocation = Vector2(0,0)
var shotgunpwrlocation = Vector2(0,0)
var dmguppwrlocation = Vector2(0,0)
var shieldpwrlocation = Vector2(0,0)
var rapidfirepwrlocation = Vector2(0,0)
var processed_location = Vector2(0,0)

@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _ready():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	global.enemy_rapid = false
	global.enemy_shotgun = false
	global.enemy_damage = false
	if global.selected_level == "res://Scenes/level.tscn":
		powerup_locations = [Vector2(194,327), Vector2(210,455), Vector2(392,556), Vector2(594,315), Vector2(751,204)]
		missilepwrlocation = Vector2(194,327)
		shotgunpwrlocation = Vector2(210,455)
		dmguppwrlocation = Vector2(392,556)
		shieldpwrlocation = Vector2(594,315)
		rapidfirepwrlocation = Vector2(751,204)
	elif global.selected_level == "res://Scenes/level2.tscn":
		pass

func _shoot(deviation, type):
	print(bullet_scene)
	if bullet_scene == null:
		print("Error: bullet_scene is not assigned!")
		return
	if missile == 1:
		projectile = missile_scene.instantiate()
	else:
		projectile = bullet_scene.instantiate()
	projectile.position = $ProjectileSpawn.global_position
	projectile.rotation = rotation + deviation
	get_parent().add_child(projectile)

func _cooldown_done():
	loaded = true

func take_damage(amount):
	global.ai_health -= amount
	print("takingdamage")
	if global.ai_health <= 0:
		die()

func _shield_down():
	immunity = false
	
func _shield_powerup_collected():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	shield = true
	immunity = true
	
func _missile_powerup_collected():
	missile = 1

func _mine_collision():
	if immunity == false:
		take_damage(30)
	else:
		$Shieldframes.play()
		shield = false
	knockback = (position - global.spacemine_collision_pos_p1)
	velocity += knockback * 15

func _damage_up():
	global.enemy_damage = true
	$Damagetimer.start(10)

func _rapid_fire():
	global.enemy_rapid = true
	reload_period = 0.2
	$Rapidtimer.start(10)

func _shotgun():
	global.enemy_shotgun = true
	$Shotguntimer.start(10)
	
func _on_rapidtimer_timeout():
	global.enemy_rapid = false
	reload_period = 0.5

func _on_damagetimer_timeout():
	global.enemy_damage = false

func _on_shotguntimer_timeout():
	global.enemy_shotgun = false
	
func _hit(projectile, bullet_vel, damage):
	if shield == true and $Shieldframes.is_playing() == false:
		shield = false
		$Shieldframes.play()
	if immunity == false:
		if projectile.is_in_group("p2_bullet"):
			take_damage(damage)
			velocity += bullet_vel * 0.3 * projectile.get_scale()
		if projectile.is_in_group("p2_missile"):
			take_damage(damage * 2.5)
			if projectile.get_scale() == Vector2(0.7,0.7):
				ko_scale = 0.06
			else:
				ko_scale = 0.15
			velocity += bullet_vel * ko_scale * projectile.get_scale()
			#shipvector += (bullet_vel * 0.0005 * bullet.get_scale())
		
func die():
	global.ai_health = 100
	global.p2_score += 1
	position = Vector2(120, 150)
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	shield = true
	immunity = true

func _physics_process(delta):
	# Check the game mode
	if global.game_mode == 1:
		
		velocity = Vector2.ZERO 
		visible = false
		position = Vector2(-101, 151)        
		return  # Exit the function early to prevent any further processing
	else:
		visible = true          


	global.ai_position = position
	
	
	if global.ai_health < 30:
		$SmokeTrail.emitting = true
		
	else:
		$SmokeTrail.emitting = false
		
	target = global.p2_position
	
	for location in powerup_locations:
		processed_location = location
		if global.missilepowerhidden == true:
			if location == missilepwrlocation:
				processed_location = global.p2_position
		if global.shotgunpowerhidden == true:
			if location == shotgunpwrlocation:
				processed_location = global.p2_position
		if global.dmgpowerhidden == true:
			if location == dmguppwrlocation:
				processed_location = global.p2_position
		if global.shieldpowerhidden == true:
			if location == shieldpwrlocation:
				processed_location = global.p2_position
		if global.rapidpowerhidden == true:
			if location == rapidfirepwrlocation:
				processed_location = global.p2_position
				
		target_check = position.distance_to(processed_location)
		if target_check < (position.distance_to(target)):
			target = processed_location
	
	nav.target_position = target
	
	# Get the next path position 
	var direction = nav.get_next_path_position() - global_position
	
	
	direction = direction.normalized()
	
	# Calculate the speed reduction factor based on the distance to the player
	var distance_to_player = global_position.distance_to(global.p2_position)
	var speed_factor = clamp((distance_to_player - min_distance) / min_distance, 0, 1)
	
	# Smooth rotation towards the movement direction
	if direction != Vector2.ZERO:
		var target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, accel * delta * 2)

	# Adjust the velocity based on the distance to the player and the direction
	velocity = velocity.lerp(direction * speed * speed_factor, accel * delta)
	
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
				missile = 0
				$Timer.start(reload_period)
				
	
	move_and_slide()



