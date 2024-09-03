extends CharacterBody2D

@onready var global = get_node("/root/Global")
var speed = 10000
var acceleration = 0
var target_rotation = 3.14
var shipvector = Vector2(0,0)
var shipvectorforward = Vector2(0,0)
var shipvectorbackward = Vector2(0,0)
@export var bullet_p2_scene: PackedScene
@export var missile_p2_scene: PackedScene
var can_shoot = true
@onready var p2 = $Player2
var knockback = Vector2(0,0)
var score = 0
var cancool = true
var is_overheated = false
var shotgun = false
var base_gundamage = 20
var big_bullet = false
var shield = true
var immunity = true
var missile = 0
var angle_list = []
signal shield_animation

func _ready():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	global.p2_gundamagepowerup = false
	global.p2_health = 100
	global.p2_gunheat = 0
	global.p2_firerate = 0.3
	global.p2_gundamage = base_gundamage
	global.p2_coolingrate = 3
	$Timer.wait_time = global.p2_firerate
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Area2D/SmokeTrail.emitting = false

# damage detection
func _hit(projectile, bullet_vel):
	if shield == true and $Shieldframes.is_playing() == false:
		shield = false
		$Shieldframes.play()
	if immunity == false:
		if projectile.is_in_group("p1_bullet"):
			take_damage(global.p1_gundamage)
			shipvector += (bullet_vel * 0.0005 * projectile.get_scale())
		if projectile.is_in_group("p1_missile"):
			take_damage(global.p1_gundamage * 2.5)
			shipvector += (bullet_vel * 0.0005 * projectile.get_scale())
		if projectile.is_in_group("enemy_bullet"):
			take_damage(20)
			shipvector += (bullet_vel * 0.0005 * projectile.get_scale())


func _shield_down():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(1,0.0)
	immunity = false
	
func _shield_powerup_collected():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	shield = true
	immunity = true

func _missile_powerup_collected():
	missile = 1

# Powerup detections
func _shotgun_powerup_collected():
	base_gundamage = 5
	shotgun = true
	$ShotgunTimer.start(10)

func _on_shotgun_timer_timeout():
	base_gundamage = 20
	shotgun = false

# Function to handle the rapid-fire power-up
func _on_rapidfire_entered(area):
	if area.has_meta("rapidfire"):
		global.p2_firerate = 0.1
		global.p2_coolingrate = 8
		print("Power-up triggered")
		print(global.p2_firerate)
		
		# StartRapidFireTimer
		$RapidFireTimer.start(10)  

# Function to reset the fire rate and cooling rate
func _on_RapidFireTimer_timeout():
	global.p2_firerate = 0.3 
	global.p2_coolingrate = 3
	$Timer.wait_time = global.p2_firerate
	print("Power-up ended")
	print(global.p2_firerate)
	
	# Damage booster powerup
func _on_damagepowerup_entered(area):
	if area.has_meta("damageincrease"):
		$DamageBoostTimer.start(10)
		big_bullet = true

func _on_DamagePowerupTimer_timeout():
	big_bullet = false
	
func take_damage(amount):
	global.p2_health -= amount
	if global.p2_health <= 0:
		die()
		
func _mine_collision():
	knockback = (position - global.spacemine_collision_pos_p2)
	shipvector += knockback * 0.07
	if immunity == false:
		take_damage(30)
	else:
		$Shieldframes.play()
		shield = false

func die():
	$Area2D/SmokeTrail.emitting = false
	global.p2_health = 100 
	global.p1_score += 1
	global.p2_gunheat = 0
	print(global.p1_score)
	#get_tree().reload_current_scene()
	position = Vector2(1020, 500)
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	shield = true
	immunity = true
	shipvector = Vector2(0,0)
	

func _shoot(deviation, type):
	var bullet = bullet_p2_scene.instantiate()
	var missile = missile_p2_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	missile.position = $ProjectileSpawn.global_position
	missile.rotation = rotation + deviation
	if big_bullet == true:
		if shotgun == true:
			bullet.set_scale(Vector2(1.4,1.4))
			missile.set_scale(Vector2(1.4,1.4))
		else:
			bullet.set_scale(Vector2(2,2))
			missile.set_scale(Vector2(2,2))
		global.p2_gundamage = base_gundamage * 2
		global.p2_bulletspeed = 0.7
	else:
		if shotgun == true:
			bullet.set_scale(Vector2(0.7,0.7))
			missile.set_scale(Vector2(0.7,0.7))
		global.p2_bulletspeed = 1
		global.p2_gundamage = base_gundamage
	if type == "missile":
		get_parent().add_child(missile)
	if type == "bullet":
		get_parent().add_child(bullet)

func _on_timer_timeout():
	can_shoot = true
	
func _ast_vel_transfer(amount):
	shipvector -= amount

func _on_overheat_timer_timeout():
	is_overheated = false
	can_shoot = true

	
	
func _physics_process(delta):
	global.p2_position = position
	global.p2_velocity = shipvector
	# Constrain the player's position within the camera limits
	position.x = clamp(position.x, CameraLimits.limit_left, CameraLimits.limit_right)
	position.y = clamp(position.y, CameraLimits.limit_top, CameraLimits.limit_bottom)

	# Outputs ship velocity by adding acceleration subtracted by friction
	shipvectorforward = Vector2(transform.x * acceleration * delta)
	shipvector += shipvectorforward - shipvectorbackward
	# Calculates friction vector
	

	if shipvector.x >= 0:
		shipvectorbackward.x = 0.01 * (pow((shipvector.x + 1.2), 3) - 1.728)
	if shipvector.x <= 0:
		shipvectorbackward.x = 0.01 * (pow((shipvector.x - 1.2), 3) + 1.728)
	if shipvector.y >= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y + 1.2), 3) - 1.728)
	if shipvector.y <= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y - 1.2), 3) + 1.728)
		
	velocity = 400 * shipvector
	#old
	#shipvectorbackward.x = 0.00001 * (pow((shipvector.x), 3))
	#shipvectorbackward.y = 0.00001 * (pow((shipvector.y), 3))

	#heat cooldown
	if global.p2_gunheat > 0 and cancool:
		global.p2_gunheat -= global.p2_coolingrate * delta
		#print("cooling", global.p2_gunheat)
		if global.p2_gunheat < 0:
			global.p2_gunheat = 0
			
	# Jank but it works ig // shot detection for guncooldown
	if Input.is_action_pressed("ui_spacebar"):
		cancool = true
	else:
		cancool = true
	
	global.p2_location = -10 * transform.x + position
	
	#damagepowerup timer/visual representation
	if global.p2_gundamagepowerup == true:
		pass #not funtioning yet
	
	#smoke trail activation
	if global.p2_health < 30:
		$Area2D/SmokeTrail.emitting = true
		
		
	
	# Movement input
	if Input.is_action_pressed("ui_up"):
		acceleration = 2
	else:
		acceleration = 0
	# Rotation input
	if Input.is_action_pressed("ui_left"):
		target_rotation -= 0.075
	elif Input.is_action_pressed("ui_right"):
		target_rotation += 0.075

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, 0.25)
	
	# detecting for if player can shoot when key is pressed
	if Input.is_action_pressed("ui_spacebar") and can_shoot and not is_overheated:
		if global.p2_gunheat < global.p2_maxgunheat:
			if shotgun == true:
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
			missile = 1
			global.p2_gunheat += 2
			can_shoot = false
			$Timer.start(global.p2_firerate)
		else: 
			is_overheated = true
			global.p2_gunheat = 10
			can_shoot = false
			$OverheatTimer.start(1)
			
			
	if cancool == false:
		$CooldownTimer.start(1)

	# Apply velocity and move the character
	move_and_slide()


