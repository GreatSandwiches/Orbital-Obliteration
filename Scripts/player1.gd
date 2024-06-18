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
@onready var global = get_node("/root/Global")

func _ready():
	global.p1_health = 100
	global.p1_gunheat = 0
	$Timer.wait_time = shoot_cooldown
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))


func _hit(area):
	if area.is_in_group("p2_bullet"):
		take_damage(20)
		
func take_damage(amount):
	global.p1_health -= amount
	if global.p1_health <= 0:
		die()
		


func die():
	global.p1_health = 100
	global.p2_score +=1
	global.p1_gunheat = 0
	get_tree().reload_current_scene()
	
func _shoot():
	var bullet = bullet_p1_scene.instantiate()
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
		
	#old
	#shipvectorbackward.x = 0.00001 * (pow((shipvector.x), 3))
	#shipvectorbackward.y = 0.00001 * (pow((shipvector.y), 3))
	
	#current position identifier for use with trail
	global.p1_location = -25 * transform.x + position
	
	velocity = 500 * shipvector
	
	
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
	rotation = lerp_angle(rotation, target_rotation, 0.1)
	
	# detecting for if player can shoot when key is pressed
	if Input.is_action_pressed("ui_spacebar") and can_shoot:
		if global.p1_gunheat < global.p1_maxgunheat:
			_shoot()
			global.p1_gunheat += 4
			can_shoot = false
			$Timer.start()
			
		
	# Apply velocity and move the character
	move_and_slide()






