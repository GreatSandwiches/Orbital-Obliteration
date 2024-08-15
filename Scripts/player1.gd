extends CharacterBody2D

var speed = 10000
var acceleration = 0
var target_rotation = 0
var shipvector = Vector2(0,0)
var shipvectorforward = Vector2(0,0)
var shipvectorbackward = Vector2(0,0)
@export var bullet_p1_scene: PackedScene
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


func _ready():
	
		
	global.p1_health = 100
	global.p1_gunheat = 0
	global.p1_firerate = 0.3
	global.p1_gundamage = base_gundamage
	global.p1_coolingrate = 3
	global.p1_bulletspeed = 1
	global.p1_maxgunheat = 10
	$Timer.wait_time = shoot_cooldown
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))

# Bullet dmg and knockback code
func _hit(bullet, bullet_vel):
	if bullet.is_in_group("p2_bullet"):
		take_damage(global.p2_gundamage)
		shipvector += (bullet_vel * 0.0005 * bullet.get_scale())
	if bullet.is_in_group("enemy_bullet"):
		take_damage(20)
		shipvector += (bullet_vel * 0.0005 * bullet.get_scale())
	
func take_damage(amount):
	global.p1_health -= amount
	if global.p1_health <= 0:
		die()
		
func _mine_collision():
	knockback = (position - global.spacemine_collision_pos_p1)
	print(knockback)
	shipvector += knockback * 0.07
	take_damage(30)

func die():
	global.p1_health = 100
	global.p2_score +=1
	global.p1_gunheat = 0
	position = Vector2(120, 150)
	
func _shoot(deviation):
	var bullet = bullet_p1_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	if big_bullet == true:
		bullet.set_scale(Vector2(2,2))
		global.p1_gundamage = base_gundamage * 2
		global.p1_bulletspeed = 0.7
	else:
		global.p1_bulletspeed = 1
		global.p1_gundamage = base_gundamage
	get_parent().add_child(bullet)
	
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
		global.p1_firerate = 0.1
		global.p1_coolingrate = 8
		print("Power-up triggered")
		print(global.p1_firerate)
		
		# Start the RapidFireTimer
		$RapidFireTimer.start(10)  # 10 seconds duration

# Function to reset the fire rate and cooling rate
func _on_RapidFireTimer_timeout():
	global.p1_firerate = 0.3  # Reset to default 
	global.p1_coolingrate = 3  # Reset to default 
	print("Power-up ended")
	print(global.p1_firerate)
	
	
func _on_damagepowerup_entered(area):
	if area.has_meta("damageincrease"):
		$DamageBoostTimer.start(10)
		big_bullet = true


func _on_DamagePowerupTimer_timeout():
	big_bullet = false
	


func _on_timer_timeout():
	can_shoot = true


func _ast_vel_transfer(amount, angle):
	shipvector -= amount / 500
	var rotate = angle + PI - shipvector.angle()
	shipvector = shipvector.rotated(rotate)
	
	
func _on_overheat_timer_timeout():
	is_overheated = false
	can_shoot = true
	

func _process(delta):
	
	if global.game_mode == 0:
		visible = false
		velocity = Vector2.ZERO
		queue_free()
		return
	
	
	
	
	global.p1_position = position
	global.p1_velocity = velocity
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
		
	#old
	#shipvectorbackward.x = 0.00001 * (pow((shipvector.x), 3))
	#shipvectorbackward.y = 0.00001 * (pow((shipvector.y), 3))
	
	#current position identifier for use with trail
	global.p1_location = -10 * transform.x + position
	
	velocity = 400 * shipvector
	
	#smoke trail activation
	if global.p1_health < 30:
		$Area2D/SmokeTrail.emitting = true
		
	else:
		$Area2D/SmokeTrail.emitting = false
	
	#heat cooldown functionality
	if global.p1_gunheat > 0 and cancool:
		global.p1_gunheat -= global.p1_coolingrate * delta
		if global.p1_gunheat < 0:
			global.p1_gunheat = 0
	
	# Jank but it works ig // shot detection for guncooldown
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
		target_rotation -= 0.075
	elif Input.is_action_pressed("ui_d"):
		target_rotation += 0.075

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, 1)
	
	# detecting for if player can shoot when key is pressed - added proper overheat detection 7/8
	if Input.is_action_pressed("ui_spacebar") and can_shoot and not is_overheated:
		if global.p1_gunheat < global.p1_maxgunheat:
			# Code for generating shotgun bullets
			if shotgun == true:
				for deviation in [(-2*PI/36), (-1*PI/36), 0, (1*PI/36), (2*PI/36)]:
					#var rng = RandomNumberGenerator.new()
					#global.p1_bulletspeed = 1 + rng.randf_range(-0.2, 0)
					_shoot(deviation)
					global.p1_gunheat += 0.1
			else:	
				_shoot(0)
			global.p1_gunheat += 2
			can_shoot = false
			$Timer.start(global.p1_firerate)
		else:
			is_overheated = true
			global.p1_gunheat = 10
			can_shoot = false
			$OverheatTimer.start(1)
			
		
	# Apply velocity and move the character
	move_and_slide()


