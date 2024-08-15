extends CharacterBody2D

@onready var global = get_node("/root/Global")
@export var bullet_scene: PackedScene

var speed = 200
var accel = 2
var min_distance = 150
var loaded = true
@onready var nav: NavigationAgent2D = $NavigationAgent2D

# Raycasts
@onready var raycast_front = $raycast_front
@onready var raycast_left = $raycast_left
@onready var raycast_right = $raycast_right

func _shoot():
	if bullet_scene == null:
		print("Error: bullet_scene is not assigned!")
		return
		
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)

func _cooldown_done():
	loaded = true
	
func _physics_process(delta):
	# Set the target position to the player's position
	nav.target_position = global.p2_position
	
	# Get the next path position from the NavigationAgent2D
	var direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	# Calculate the speed reduction factor based on the distance to the player
	var distance_to_player = global_position.distance_to(global.p2_position)
	var speed_factor = clamp((distance_to_player - min_distance) / min_distance, 0, 1)
	
	# Rotate the enemy to face the direction it's moving
	if direction != Vector2.ZERO:
		rotation = direction.angle()

	# Obstacle avoidance using raycasts
	var avoid_direction = Vector2.ZERO

	if raycast_front.is_colliding():
		# If there's something directly ahead, steer left or right
		if raycast_left.is_colliding() and !raycast_right.is_colliding():
			avoid_direction = direction.rotated(-PI/4)  # Turn right
		elif !raycast_left.is_colliding() and raycast_right.is_colliding():
			avoid_direction = direction.rotated(PI/4)  # Turn left
		else:
			avoid_direction = direction.rotated(PI/2)  # Turn sharply if both sides are blocked

	# If an avoid_direction was determined, use it
	if avoid_direction != Vector2.ZERO:
		direction = avoid_direction.normalized()

	
	velocity = velocity.lerp(direction * speed * speed_factor, accel * delta)
	
	# Shooting logic
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			if loaded == true:
				_shoot()
				loaded = false
				$Timer.start(1)
				
	# Move the character 
	move_and_slide()

# Helper function to draw the raycast in the editor (for debugging)
# remove for final game
func _draw():
	draw_line(Vector2(), raycast_front.target_position, Color(1, 0, 0))
	draw_line(Vector2(), raycast_left.target_position, Color(0, 1, 0))
	draw_line(Vector2(), raycast_right.target_position, Color(0, 0, 1))
