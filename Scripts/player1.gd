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
@onready var global = get_node("/root/Global")
var is_overheated = false


func _ready():
	global.p1_health = 100
	global.p1_gunheat = 0
	global.p1_firerate = 0.3
	global.p1_gundamage = 20
	global.p1_coolingrate = 3
	$Timer.wait_time = shoot_cooldown
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _hit(area):
	if area.is_in_group("p2_bullet"):
		take_damage(global.p2_gundamage)
		
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
	
func _shoot():
	var bullet = bullet_p1_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	
	
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
		global.p1_gundamage = 50
		print(global.p2_gundamage)
		$DamageBoostTimer.start(10)


func _on_DamagePowerupTimer_timeout():
	global.p1_gundamage = 20
	print("Damagepowerup ended")
	
	
	
func _on_timer_timeout():
	can_shoot = true

func _ast_vel_transfer(amount):
	shipvector -= amount / 500
	
	
func _on_overheat_timer_timeout():
	is_overheated = false
	can_shoot = true
	

func _process(delta):
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
		shipvectorbackward.x = 0.01 * (pow((shipvector.x + 1), 3) - 1)
	if shipvector.x <= 0:
		shipvectorbackward.x = 0.01 * (pow((shipvector.x - 1), 3) + 1)
	if shipvector.y >= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y + 1), 3) - 1)
	if shipvector.y <= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y - 1), 3) + 1)
		
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
	if Input.is_action_pressed("ui_spacebar"):
		cancool = true
	else:
		cancool = true
	
	# Movement input
	if Input.is_action_pressed("ui_up"):
		acceleration = 2
	else:
		acceleration = 0
	# Rotation input
	if Input.is_action_pressed("ui_left"):
		target_rotation -= 0.1
	elif Input.is_action_pressed("ui_right"):
		target_rotation += 0.1

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, 0.25)
	
	# detecting for if player can shoot when key is pressed - added proper overheat detection 7/8
	if Input.is_action_pressed("ui_spacebar") and can_shoot and not is_overheated:
		if global.p1_gunheat < global.p1_maxgunheat:
			_shoot()
			global.p1_gunheat += 2
			can_shoot = false
			$Timer.start(global.p1_firerate)
		else:
			is_overheated = true
			can_shoot = false
			$OverheatTimer.start(2)
			
		
	# Apply velocity and move the character
	move_and_slide()




