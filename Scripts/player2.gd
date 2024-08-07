extends CharacterBody2D

@onready var global = get_node("/root/Global")
var speed = 10000
var acceleration = 0
var target_rotation = 3.14
var shipvector = Vector2(0,0)
var shipvectorforward = Vector2(0,0)
var shipvectorbackward = Vector2(0,0)
@export var bullet_p2_scene: PackedScene
var can_shoot = true
@onready var p2 = $Player2
var knockback = Vector2(0,0)
var score = 0
var cancool = true
var is_overheated = false
@onready var healthbar = $CanvasLayer/HealthBar
@onready var health = global.p2_health

func _ready():
	print(rotation_degrees)
	global.p2_gundamagepowerup = false
	health = 100
	global.p2_gunheat = 0
	global.p2_firerate = 0.3
	global.p2_gundamage = 20
	global.p2_coolingrate = 3
	$Timer.wait_time = global.p2_firerate
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Area2D/SmokeTrail.emitting = false
	healthbar._init_health(health)

# damage detection
func _on_area_2d_area_entered(area):
	if area.is_in_group("p1_bullet"):
		take_damage(global.p1_gundamage)
		
# Powerup detections

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
		global.p2_gundamagepowerup = true
		global.p2_gundamage = 50
		print(global.p2_gundamage)
		$DamageBoostTimer.start(10)


func _on_DamagePowerupTimer_timeout():
	global.p2_gundamage = 20
	global.p2_gundamagepowerup = false
	print("Damagepowerup ended")
	
	
		
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
	
	healthbar.health = health
		
func _mine_collision():
	knockback = (position - global.spacemine_collision_pos_p2)
	print(knockback)
	shipvector += knockback * 0.07
	take_damage(30)

func die():
	$Area2D/SmokeTrail.emitting = false
	health = 100
	global.p1_score += 1
	global.p2_gunheat = 0
	print(global.p1_score)
	#get_tree().reload_current_scene()
	position = Vector2(1000, 530)
	
func _shoot():
	var bullet = bullet_p2_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
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
		shipvectorbackward.x = 0.01 * (pow((shipvector.x + 1), 3) - 1)
	if shipvector.x <= 0:
		shipvectorbackward.x = 0.01 * (pow((shipvector.x - 1), 3) + 1)
	if shipvector.y >= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y + 1), 3) - 1)
	if shipvector.y <= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y - 1), 3) + 1)
		
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
	if Input.is_action_pressed("ui_shift"):
		cancool = true
	else:
		cancool = true
	
	global.p2_location = -10 * transform.x + position
	
	#damagepowerup timer/visual representation
	if global.p2_gundamagepowerup == true:
		pass #not funtioning yet
	
	#smoke trail activation
	if health < 30:
		$Area2D/SmokeTrail.emitting = true
	
	else:
		$Area2D/SmokeTrail.emitting = false
		
	
	global.p2_health = health	#updating global var
		
	
	# Movement input
	if Input.is_action_pressed("ui_w"):
		acceleration = 2
	else:
		acceleration = 0
	# Rotation input
	if Input.is_action_pressed("ui_a"):
		target_rotation -= 0.1
	elif Input.is_action_pressed("ui_d"):
		target_rotation += 0.1

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, 1)
	
	# detecting for if player can shoot when key is pressed
	if Input.is_action_pressed("ui_shift") and can_shoot and not is_overheated:
		if global.p2_gunheat < global.p2_maxgunheat:
			_shoot()
			global.p2_gunheat += 2
			can_shoot = false
			$Timer.start(global.p2_firerate)
		else: 
			is_overheated = true
			can_shoot = false
			$OverheatTimer.start(2)
			
			
	if cancool == false:
		$CooldownTimer.start(1)

	# Apply velocity and move the character
	move_and_slide()












