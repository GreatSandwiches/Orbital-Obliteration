extends CharacterBody2D

var speed = 10000
var acceleration = 0
var target_rotation = 0
var shipvector = Vector2(0,0)
var shipvectorforward = Vector2(0,0)
var shipvectorbackward = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _process(delta):
	#outputs ship velocity by adding acceleration subtracted by friction
	shipvectorforward = Vector2(transform.x * 500 * acceleration * delta)
	shipvector += shipvectorforward - shipvectorbackward
	#claculates friction vector
	shipvectorbackward.x = 0.0000001 * (pow((shipvector.x), 3))
	shipvectorbackward.y = 0.0000001 * (pow((shipvector.y), 3))
	
	velocity = shipvector
	# Movement input
	if Input.is_action_pressed("ui_up"):
		acceleration = 1
	else:
		acceleration = 0
	# Rotation input
	if Input.is_action_pressed("ui_left"):
		target_rotation -= 0.1
	elif Input.is_action_pressed("ui_right"):
		target_rotation += 0.1

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, 0.1)

	# Print the current rotation in degrees
	#print(rad_to_deg(rotation))
	
	print(shipvector)
	# Apply velocity and move the character
	move_and_slide()
