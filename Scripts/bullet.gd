extends Area2D
@export var speed = 400
@export var lifetime = 2.0
var velocity = Vector2.ZERO

func _ready():
	# Calculate the velocity based on the rotation
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	
	# Create a timer to handle the bullet's lifetime
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	add_child(timer)
	timer.start() 
	
	# Use await to queue_free the bullet after 'lifetime' seconds
	await timer.timeout
	queue_free()
	print("bullet")

func _process(delta):
	# Move the bullet forward in the direction it is facing
	position += velocity * delta
	
func _on_area_entered(area):
	if area.is_in_group("players"):
		area.take_damage(10)
		queue_free()
		print("jfr")




