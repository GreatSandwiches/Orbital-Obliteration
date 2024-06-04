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
var health = 100

func _ready():
	$Timer.wait_time = shoot_cooldown
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	get_tree().reload_current_scene()
	
func _shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	
func _on_timer_timeout():
	can_shoot = true

func _process(delta):
	# Outputs ship velocity by adding acceleration subtracted by friction
	shipvectorforward = Vector2(transform.x * 500 * acceleration * delta)
	shipvector += shipvectorforward - shipvectorbackward
	# Calculates friction vector
	shipvectorbackward.x = 0.00001 * (pow((shipvector.x), 3))
	shipvectorbackward.y = 0.00001 * (pow((shipvector.y), 3))
	
	velocity = shipvector
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
	
	if Input.is_action_pressed("ui_shift") and can_shoot:
		_shoot()
		can_shoot = false
		$Timer.start()
		
	# Apply velocity and move the character
	move_and_slide()
