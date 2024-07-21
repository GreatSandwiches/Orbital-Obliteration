extends RigidBody2D

@onready var global = get_node("/root/Global")

var velocity = Vector2(8,0)	
var vertical = false
var horizontal = false
var vel_change = Vector2(0,0)


func _wallhit(place):
	var difference = position - global.wall_pos1
	var angle = difference.angle()
	if place == "vertical hitbox":
		print(place)
		velocity.y = velocity.y * -1
	elif place == "horizontal hitbox":
		print(place)
		velocity.x = velocity.x * -1
	else:
		print(place)
		var needed_rotation =  difference.angle() - velocity.angle()
		velocity = velocity.rotated(needed_rotation)
	velocity = velocity * 0.9


func _main_hitbox(area):
	pass
	
			
func _vertical_hbx(area):
	#if area.is_in_group("wall"):
	#	var vertical = true
	#	velocity.y = velocity.y * -1
	#	print(vertical)
	pass
		
func vertical_exited(area):
	if area.is_in_group("wall"):
		var vertical = false

func _horizontal_hbx(area):
	#if area.is_in_group("wall"):
	#	var horizontal = true
	#	velocity.x = velocity.x * -1
	#	print(horizontal)
	pass
		
func _horizontal_exited(area):
	if area.is_in_group("wall"):
		var horizontal = false

func _physics_process(delta):
	move_and_collide(velocity)
	global.asteroid1_pos = position

