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

var score = 0
var cancool = true

func _ready():
	print(rotation_degrees)
	global.p2_health = 100
	global.p2_gunheat = 0
	global.p2_firerate = 0.5
	global.p2_gundamage = 20
	$Timer.wait_time = global.p2_firerate
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))

# damage detection
func _on_area_2d_area_entered(area):
	if area.is_in_group("p1_bullet"):
		take_damage(global.p1_gundamage)
		
# Powerup detections

# Function to handle the rapid-fire power-up
func _on_rapidfire_entered(area):
	if area.has_meta("rapidfire"):
		global.p2_firerate = 0.2
		global.p2_coolingrate = 15
		$Timer.wait_time = global.p2_firerate
		print("Power-up triggered")
		print(global.p2_firerate)
		
		# StartRapidFireTimer
		$RapidFireTimer.start(10)  

# Function to reset the fire rate and cooling rate
func _on_RapidFireTimer_timeout():
	global.p2_firerate = 0.5   
	global.p2_coolingrate = 3  
	$Timer.wait_time = global.p2_firerate
	print("Power-up ended")
	print(global.p2_firerate)
	
	# Damage booster powerup
func _on_damagepowerup_entered(area):
	if area.has_meta("damageincrease"):
		global.p2_gundamage = 50
		
		$DamageBoostTimer.start(10)


func _on_DamagePowerupTimer_timeout():
	global.p2_gundamage = 20
	print("Damagepowerup ended")
	
	
		
func take_damage(amount):
	global.p2_health -= amount
	if global.p2_health <= 0:
		die()
		
func _mine_collision(area):
	if area.is_in_group("space_mine"):
		shipvector = -shipvector * 2
		take_damage(30)

func die():
	global.p2_health = 100 
	global.p1_score += 1
	global.p2_gunheat = 0
	print(global.p1_score)
	get_tree().reload_current_scene()
	
func _shoot():
	var bullet = bullet_p2_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)

func _on_timer_timeout():
	can_shoot = true

func _process(delta):
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
		
	velocity = 500 * shipvector
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
	
	global.p2_location = -25 * transform.x + position
	
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
	rotation = lerp_angle(rotation, target_rotation, 0.1)
	
	# detecting for if player can shoot when key is pressed
	if Input.is_action_pressed("ui_shift") and can_shoot:
		if global.p2_gunheat < global.p2_maxgunheat:
			_shoot()
			global.p2_gunheat += 4
			can_shoot = false
			$Timer.start()

	# Apply velocity and move the character
	move_and_slide()






