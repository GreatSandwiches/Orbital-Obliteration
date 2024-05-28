extends CharacterBody2D

var speed = 10000
var acceleration = 2
var shipvelocity = 0
var friction = 0
var target_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _process(delta):
	#friction calculation based off velocity
	friction = pow(1.2, (shipvelocity - 8))
	#moves ship forward constantly based off shipvelocity
	velocity = transform.x * 10 * ((shipvelocity * delta)-(friction * delta))
	# Movement input
	if Input.is_action_pressed("ui_up"):
		shipvelocity += acceleration
	elif Input.is_action_pressed("ui_down"):
		shipvelocity -= acceleration
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
	#print(rad_to_deg(rotation))
	print(shipvelocity)
	# Apply velocity and move the character
	move_and_slide()
