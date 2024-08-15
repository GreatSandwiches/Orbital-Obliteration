extends CharacterBody2D
@onready var global = get_node("/root/Global")

var speed = 200
var accel = 2

@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta):
	
	
	var direction = Vector3()
	nav.target_position = global.p2_position

	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()

	velocity = velocity.lerp(direction * speed, accel * delta)

	move_and_slide()
