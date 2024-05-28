extends CharacterBody2D

var speed = 10000
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_up"):
		velocity = transform.x * speed * delta
	if Input.is_action_pressed("ui_down"):
		velocity = -transform.x * speed * delta
	if Input.is_action_pressed("ui_left"):
		self.rotate(-0.1)
	if Input.is_action_pressed("ui_right"):
		self.rotate(0.1)
	if not Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
		velocity = lerp(velocity, Vector2(0.0, 0.0), 0.005)
		
	print(rad_to_deg(rotation))
	
	move_and_slide()
