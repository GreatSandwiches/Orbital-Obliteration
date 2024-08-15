extends CharacterBody2D
@onready var global = get_node("/root/Global")
@export var bullet_scene: PackedScene
var speed = 180
var accel = 2
var min_distance = 150
var loaded = true

@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _shoot():
	print(bullet_scene)
	if bullet_scene == null:
		print("Error: bullet_scene is not assigned!")
		return
		
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)

func _cooldown_done():
	loaded = true
	
	
func take_damage(amount):
	global.ai_health -= amount
	print("takingdamage")
	if global.ai_health <= 0:
		die()
		
func _hit(bullet, bullet_vel):
	if bullet.is_in_group("p2_bullet"):
		take_damage(global.p2_gundamage)
		#shipvector += (bullet_vel * 0.0005 * bullet.get_scale())
		
func die():
	global.ai_health = 100
	position = Vector2(120, 150)

func _physics_process(delta):
	# Check the game mode
	if global.game_mode == 1:
		
		velocity = Vector2.ZERO 
		visible = false         
		return  # Exit the function early to prevent any further processing
	else:
		visible = true          

	# Set the target position to the player's position
	nav.target_position = global.p2_position
	
	# Get the next path position from the NavigationAgent2D
	var direction = nav.get_next_path_position() - global_position
	
	# Normalize the direction vector
	direction = direction.normalized()
	
	# Calculate the speed reduction factor based on the distance to the player
	var distance_to_player = global_position.distance_to(global.p2_position)
	var speed_factor = clamp((distance_to_player - min_distance) / min_distance, 0, 1)
	
	# Smooth rotation towards the movement direction
	if direction != Vector2.ZERO:
		var target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, accel * delta)

	# Adjust the velocity based on the distance to the player and the direction
	velocity = velocity.lerp(direction * speed * speed_factor, accel * delta)
	
	# Shooting logic
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			if loaded == true:
				_shoot()
				loaded = false
				$Timer.start(1)
				
	# Move the character and handle collisions
	move_and_slide()
