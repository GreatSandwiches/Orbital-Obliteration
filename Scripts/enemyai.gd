extends CharacterBody2D
@onready var global = get_node("/root/Global")
@export var bullet_scene: PackedScene
var speed = 200
var accel = 2
var min_distance = 100 
var loaded = true
@onready var nav: NavigationAgent2D = $NavigationAgent2D



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
	var direction = Vector2()
	nav.target_position = global.p2_position

	var distance_to_player = global_position.distance_to(global.p2_position)
	
	# Calculate the speed reduction factor based on the distance to the player
	var speed_factor = clamp((distance_to_player - min_distance) / min_distance, 0, 1)
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()

	# Rotate the enemy to face the direction it's moving
	if direction != Vector2.ZERO:
		rotation = direction.angle()

	# Adjust the velocity based on the distance to the player
	velocity = velocity.lerp(direction * speed * speed_factor, accel * delta)

	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			if loaded == true:
				_shoot()
				loaded = false
				$Timer.start(1)
				
				
	move_and_slide()
