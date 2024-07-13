extends RigidBody2D

var velocity = Vector2(0,0)

func _physics_process(delta):
	move_and_collide(velocity)


