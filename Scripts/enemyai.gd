extends CharacterBody2D
@onready var global = get_node("/root/Global")
@export var bullet_scene: PackedScene
var speed = 180
var accel = 2
var min_distance = 50
var loaded = true
var ko_scale
var reload_period = 0.5
var missile = 0
var angle_list = []

@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _shoot(deviation, type):
	print(bullet_scene)
	if bullet_scene == null:
		print("Error: bullet_scene is not assigned!")
		return
		
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	get_parent().add_child(bullet)

func _cooldown_done():
	loaded = true
	
	
func take_damage(amount):
	global.ai_health -= amount
	print("takingdamage")
	if global.ai_health <= 0:
		die()
		
func _mine_collision():
	pass

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
	
func _hit(projectile, bullet_vel):
	if projectile.is_in_group("p2_bullet"):
		take_damage(global.p2_gundamage)
		velocity += bullet_vel * 0.3 * projectile.get_scale()
	if projectile.is_in_group("p2_missile"):
		take_damage(global.p2_gundamage * 2.5)
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
		
	
	nav.target_position = global.p2_position
	
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
				$Timer.start(reload_period)
				
	
	move_and_slide()



