extends Area2D
@export var speed = 500
@export var lifetime = 2.0
@onready var global = get_node("/root/Global")
var velocity = Vector2.ZERO
signal p1_hit
signal p2_hit

func _ready():
	p1_hit.connect(get_node("/root/Level/Player1")._hit)
	#p2_hit.connect(get_node("/root/Level/Player2")._hit)
	# Calculate the velocity based on the rotation
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	# Multiplies velocity by desired bullet speed (for shotgun powerup)
	if self.is_in_group("p1_bullet"):
		velocity = velocity * global.p1_bulletspeed
		
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
	if area.is_in_group("player1"):
		if not self.is_in_group("p1_bullet"):
			p1_hit.emit(self, velocity)
			queue_free()
	if area.is_in_group("player2"):
		if not self.is_in_group("p2_bullet"):
			p2_hit.emit(self, velocity)
			queue_free()
	if area.is_in_group("wall"):
		queue_free()
