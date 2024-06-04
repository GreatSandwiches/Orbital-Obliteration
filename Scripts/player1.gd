extends CharacterBody2D

var speed = 10000
var acceleration = 0
var target_rotation = 0
var shipvector = Vector2(0,0)
var shipvectorforward = Vector2(0,0)
var shipvectorbackward = Vector2(0,0)
@export var bullet_scene: PackedScene
var can_shoot = true
var shoot_cooldown = 0.5

func _ready():
	$Timer.wait_time = shoot_cooldown
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	
func _on_timer_timeout():
	can_shoot = true

func _process(delta):
	# Outputs ship velocity by adding acceleration subtracted by friction
	shipvectorforward = Vector2(transform.x * acceleration * delta)
	shipvector += shipvectorforward - shipvectorbackward
	# Calculates friction vector
	
	# old script:
	#shipvectorbackward.x = 0.000001 * (pow((shipvector.x), 3))
	#shipvectorbackward.y = 0.000001 * (pow((shipvector.y), 3))
	
	# new script:
	if shipvector.x >= 0:
		shipvectorbackward.x = 0.01 * (pow((shipvector.x + 1), 3) - 1)
	if shipvector.x <= 0:
		shipvectorbackward.x = 0.01 * (pow((shipvector.x - 1), 3) + 1)
	if shipvector.y >= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y + 1), 3) - 1)
	if shipvector.y <= 0:
		shipvectorbackward.y = 0.01 * (pow((shipvector.y - 1), 3) + 1)
	
	velocity = 500 * shipvector
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
	
	if Input.is_action_pressed("ui_spacebar") and can_shoot:
		_shoot()
		can_shoot = false
		$Timer.start()
		
	# Apply velocity and move the character
	move_and_slide()
