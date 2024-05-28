extends CharacterBody2D

var speed = 10000
var target_rotation = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Movement input
	if Input.is_action_pressed("ui_up"):
		velocity = transform.x * speed * delta
	elif Input.is_action_pressed("ui_down"):
		velocity = -transform.x * speed * delta
	else:
		velocity = lerp(velocity, Vector2(0.0, 0.0), 0.005)

	# Rotation input
	if Input.is_action_pressed("ui_left"):
		target_rotation -= 0.1
	elif Input.is_action_pressed("ui_right"):
		target_rotation += 0.1

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, 0.1)

	# Print the current rotation in degrees
	print(rad_to_deg(rotation))

	# Apply velocity and move the character
	move_and_slide()
