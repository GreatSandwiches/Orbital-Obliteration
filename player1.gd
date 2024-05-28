extends CharacterBody2D

var speed = 10000
var acceleration = 0.3
var shipvelocity = 0.0
var shipvelocityX = 0
var shipvelocityY = 0
var friction = 0
var target_rotation = 0
var shipvector = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _process(delta):
	#friction calculation based off velocity
	friction = pow(2, (shipvelocity - 8)) - pow(2, -8)
	shipvelocity -= friction
	#moves ship forward constantly based off shipvelocity
	shipvector = transform.x * 3000 * shipvelocity * delta
	velocity = shipvector
	# Movement input
	if Input.is_action_pressed("ui_up"):
		shipvelocity += acceleration
	elif Input.is_action_pressed("ui_down"):
		pass
		#shipvelocity -= acceleration
	

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
