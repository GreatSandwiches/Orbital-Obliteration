extends RigidBody2D

@onready var global = get_node("/root/Global")

# Variables
var velocity = Vector2(0, 0)
var vertical = false
var horizontal = false
var vel_change = Vector2(0, 0)
var processing = false

# Constants
const VELOCITY_REDUCTION_FACTOR = 0.9

# Signals
signal p1_vel_transfer
signal p2_vel_transfer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p1_vel_transfer.connect(get_node("/root/Level/Player1")._ast_vel_transfer)
	p2_vel_transfer.connect(get_node("/root/Level/Player2")._ast_vel_transfer)

	# Fetch vertical and horizontal hitbox areas
	var vertical_area = get_node("/root/Level/Asteroid1").get_child(3)
	var horizontal_area = get_node("/root/Level/Asteroid1").get_child(4)


# Handle collisions with walls
func _wallhit(wall) -> void:
	var vertical_area = get_node("/root/Level/Asteroid1").get_child(3)
	var horizontal_area = get_node("/root/Level/Asteroid1").get_child(4)
	var difference = position - global.wall_pos_1
	var angle = difference.angle()
	var needed_rotation = difference.angle() - velocity.angle()
	print(needed_rotation)

	if vertical_area.overlaps_area(wall):
		if global.wall_pos_1.y > position.y and velocity.y > 0:
			velocity.y = -velocity.y
		elif global.wall_pos_1.y < position.y and velocity.y < 0:
			velocity.y = -velocity.y

	elif horizontal_area.overlaps_area(wall):
		if global.wall_pos_1.x > position.x and velocity.x > 0:
			velocity.x = -velocity.x
		elif global.wall_pos_1.x < position.x and velocity.x < 0:
			velocity.x = -velocity.x

	else:
		velocity = velocity.rotated(needed_rotation)

	velocity *= VELOCITY_REDUCTION_FACTOR


# Handle collisions with main hitbox
func _main_hitbox(area) -> void:
	if area.is_in_group("player1"):
		print("xxx")
		var velocity_diff = global.p1_velocity - velocity
		var difference = position - global.p1_position
		var angle = difference.angle()
		var needed_rotation = angle - velocity.angle()
		var old_velocity = velocity
		var vector_combination = velocity + global.p1_velocity
		var scaling = global.p1_velocity.length()

		p1_vel_transfer.emit(old_velocity, angle)
		velocity += difference * scaling
		velocity = velocity.rotated(needed_rotation)
		velocity *= VELOCITY_REDUCTION_FACTOR


# Handle vertical hitbox events
func _vertical_hbx(area) -> void:
	# Placeholder for future logic
	pass


# Handle when a vertical hitbox exits
func vertical_exited(area) -> void:
	if area.is_in_group("wall"):
		vertical = false


# Handle horizontal hitbox events
func _horizontal_hbx(area) -> void:
	# Placeholder for future logic
	pass


# Handle when a horizontal hitbox exits
func _horizontal_exited(area) -> void:
	if area.is_in_group("wall"):
		horizontal = false


# Physics processing for collision and movement
func _physics_process(delta: float) -> void:
	move_and_collide(velocity * delta)
	rotation = 0
	global.asteroid_1_pos = position
