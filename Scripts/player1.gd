extends CharacterBody2D

var speed = 10000
var acceleration = 0
var target_rotation = 0
var shipvector = Vector2(0,0)
var shipvectorforward = Vector2(0,0)
var shipvectorbackward = Vector2(0,0)
@export var bullet_p1_scene: PackedScene
@export var missile_p1_scene: PackedScene
var can_shoot = true
var shoot_cooldown = 0.5
var score = 0
var cancool = true
var knockback = Vector2(0,0)
var bullet_knockback = Vector2(0,0)
@onready var global = get_node("/root/Global")
var is_overheated = false
var big_bullet = false
var shotgun = false
var base_gundamage = 20
var shield = true
var immunity = true
var missile = 0
var angle_list = []
var max_health = 100
var default_firerate = 0.3
var default_coolingrate = 3
var overheated = 10
var rotation_amount = 0.075
var regular_bullet_speed = 1
var slowed_bullet_speed = 0.7
var starting_position = Vector2(120,150)
var mine_damage = 30
var enhanced_shotgun_size = Vector2(1.4,1.4)
var big_bullet_size = Vector2(2,2)
var shotgun_bullet_size = Vector2(0.7,0.7)

signal shield_animation
signal powered_up


# Called when the node enters the scene tree for the first time.
func _ready():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	global.p1_health = max_health
	global.p1_gunheat = 0
	global.p1_firerate = default_firerate
	global.p1_gundamage = base_gundamage
	global.p1_coolingrate = default_coolingrate
	global.p1_bulletspeed = regular_bullet_speed
	global.p1_maxgunheat = overheated
	$Timer.wait_time = shoot_cooldown
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	powered_up.connect(get_node("/root/Level/P1_UI")._powered_up)


# Bullet dmg and knockback code
func _hit(projectile, bullet_vel, damage):
	if shield == true and $Shieldframes.is_playing() == false:
		shield = false
		$Shieldframes.play()
	if immunity == false:
		if projectile.is_in_group("p2_bullet"):
			take_damage(damage)
			shipvector += (bullet_vel * 0.0005 * projectile.get_scale())
		if projectile.is_in_group("p2_missile"):
			take_damage(damage * 2.5)
			shipvector += (bullet_vel * 0.0005 * projectile.get_scale())
		if projectile.is_in_group("enemy_bullet"):
			take_damage(damage)
			shipvector += (bullet_vel * 0.0005 * projectile.get_scale())
		if projectile.is_in_group("enemy_missile"):
			take_damage(damage * 2.5)
			shipvector += (bullet_vel * 0.0005 * projectile.get_scale())


# Removes immunity when player shield runs out
func _shield_down():
	immunity = false


# Applies shield effect when shield powerup is collected
func _shield_powerup_collected():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	shield = true
	immunity = true


# Activates the missile when missile powerup is collected
func _missile_powerup_collected():
	missile = 1


# Calculates damage taken and when to execute die() function
func take_damage(amount):
	global.p1_health -= amount
	if global.p1_health <= 0:
		die()
	
	
# Damages and calculates knockback when player hits a spacemine		
func _mine_collision():
	knockback = (position - global.spacemine_collision_pos_p1)
	shipvector += knockback * 0.07
	if immunity == false:
		take_damage(mine_damage)
	else:
		$Shieldframes.play()
		shield = false


# Resetting and respawning player when they die
func die():
	global.p1_health = max_health
	global.p2_score += 1
	global.p1_gunheat = 0
	position = starting_position
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0,0.0)
	shield = true
	immunity = true
	shipvector = Vector2(0,0)
	

# Function to handle shooting of bullets	
func _shoot(deviation, type):
	var bullet = bullet_p1_scene.instantiate()
	var missile = missile_p1_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	missile.position = $ProjectileSpawn.global_position
	missile.rotation = rotation + deviation
	
	if big_bullet == true:
		if shotgun == true:
			bullet.set_scale(enhanced_shotgun_size)
			missile.set_scale(enhanced_shotgun_size)
		else:
			bullet.set_scale(big_bullet_size)
			missile.set_scale(big_bullet_size)
		global.p1_gundamage = base_gundamage * 2 # Doubling damage 
		global.p1_bulletspeed = slowed_bullet_speed
	else:
		if shotgun == true:
			bullet.set_scale(shotgun_bullet_size)
			missile.set_scale(shotgun_bullet_size)
		global.p1_bulletspeed = regular_bullet_speed
		global.p1_gundamage = base_gundamage
	if type == "missile":
		get_parent().add_child(missile)
	if type == "bullet":
		get_parent().add_child(bullet)
		print(global.p1_gundamage)
	
	
func _shotgun_powerup_collected():
	base_gundamage = 5
	shotgun = true
	$ShotgunTimer.start(10)
	powered_up.emit()


func _on_shotgun_timer_timeout():
	base_gundamage = 20
	shotgun = false


# Function to handle the rapid-fire power-up
func _on_rapidfire_entered(area):
	if area.has_meta("rapidfire"):
		global.p1_firerate = 0.1
		global.p1_coolingrate = 8
		print("Power-up triggered")
		print(global.p1_firerate)
		
		# Start the RapidFireTimer
		$RapidFireTimer.start(10)  # 10 seconds duration
		powered_up.emit()


# Function to reset the fire rate and cooling rate
func _on_RapidFireTimer_timeout():
	global.p1_firerate = default_firerate   
	global.p1_coolingrate = default_coolingrate  
	print("Power-up ended")
	print(global.p1_firerate)


func _on_damagepowerup_entered(area):
	if area.has_meta("damageincrease"):
		$DamageBoostTimer.start(10)
		big_bullet = true
		powered_up.emit()


func _on_DamagePowerupTimer_timeout():
	big_bullet = false


func _on_timer_timeout():
	can_shoot = true


func _on_overheat_timer_timeout():
	is_overheated = false
	can_shoot = true


func _process(_delta):
	if global.game_mode == 0:
		visible = false
		velocity = Vector2.ZERO
		position = Vector2(-101, 151)
		queue_free()
		return
	
	global.p1_position = position
	global.p1_velocity = velocity
	
	# Constrain the player's position within the camera limits
	position.x = clamp(position.x, CameraLimits.limit_left, CameraLimits.limit_right)
	position.y = clamp(position.y, CameraLimits.limit_top, CameraLimits.limit_bottom)

	# Outputs ship velocity by adding acceleration subtracted by friction
	shipvectorforward = Vector2(transform.x * acceleration * _delta)
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
	
	# Current position identifier for use with trail
	global.p1_location = -10 * transform.x + position
	
	velocity = 400 * shipvector
	
	# Smoke trail activation
	if global.p1_health < 30:
		$Area2D/SmokeTrail.emitting = true
		
	else:
		$Area2D/SmokeTrail.emitting = false
	
	# Heat cooldown functionality
	if global.p1_gunheat > 0 and cancool:
		global.p1_gunheat -= global.p1_coolingrate * _delta
		if global.p1_gunheat < 0:
			global.p1_gunheat = 0
	
	# Shot detection for guncooldown
	if Input.is_action_pressed("ui_shift"):
		cancool = true
	else:
		cancool = true
	
	# Movement input
	if Input.is_action_pressed("ui_w"):
		acceleration = 2
	else:
		acceleration = 0
	# Rotation input
	if Input.is_action_pressed("ui_a"):
		target_rotation -= rotation_amount
	elif Input.is_action_pressed("ui_d"):
		target_rotation += rotation_amount

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, 1)
	
	# Detecting for if player can shoot when key is pressed
	if Input.is_action_pressed("ui_shift") and can_shoot and not is_overheated:
		if global.p1_gunheat < global.p1_maxgunheat:
			# Code for generating shotgun bullets
			if shotgun == true:
				angle_list = [(-2*PI/36), (-1*PI/36), 0, (1*PI/36), (2*PI/36)]
				if missile == 1:
					angle_list = [(-2*PI/7), (-1*PI/7), 0, (1*PI/7), (2*PI/7)]
				for deviation in angle_list:
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
			missile = 0
			global.p1_gunheat += 2
			can_shoot = false
			$Timer.start(global.p1_firerate)
		else:
			is_overheated = true
			global.p1_gunheat = overheated
			can_shoot = false
			$OverheatTimer.start(1)
			
	# Apply velocity and move the character
	move_and_slide()
