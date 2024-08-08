extends RigidBody2D

@onready var global = get_node("/root/Global")

var velocity = Vector2(0,0)	
var vertical = false
var horizontal = false
var vel_change = Vector2(0,0)
signal p1_vel_transfer
signal p2_vel_transfer
var processing = false

func _ready():
	p1_vel_transfer.connect(get_node("/root/Level/Player1")._ast_vel_transfer)
	p2_vel_transfer.connect(get_node("/root/Level/Player2")._ast_vel_transfer)
	var vertical_area = get_node("/root/Level/Asteroid1").get_child(3)
	var horizontal_area = get_node("/root/Level/Asteroid1").get_child(4)

func _wallhit(wall):
	
		var vertical_area = get_node("/root/Level/Asteroid1").get_child(3)
		var horizontal_area = get_node("/root/Level/Asteroid1").get_child(4)
		var difference = position - global.wall_pos1
		var angle = difference.angle()
		var needed_rotation =  difference.angle() - velocity.angle()
		print(needed_rotation)
		
		if vertical_area.overlaps_area(wall):
			if global.wall_pos1.y > position.y:
				if velocity.y > 0:
					velocity.y = velocity.y * -1
			elif global.wall_pos1.y < position.y:
				if velocity.y < 0:
					velocity.y = velocity.y * -1
					
		elif horizontal_area.overlaps_area(wall):
			if global.wall_pos1.x > position.x:
				if velocity.x > 0:
					velocity.x = velocity.x * -1
			elif global.wall_pos1.x < position.x:
				if velocity.x < 0:
					velocity.x = velocity.x * -1

		else:
			velocity = velocity.rotated(needed_rotation)
		
		velocity = velocity * 0.9
		
	
func _main_hitbox(area):
	if area.is_in_group("player1"):
		print("xxx")
		var velocity_diff = global.p1_velocity - velocity
		var difference = position - global.p1_position
		var angle = difference.angle()
		var needed_rotation =  angle - velocity.angle()
		var old_velocity = velocity
		
		var vector_combination = velocity + global.p1_velocity
		
		var scaling = global.p1_velocity.length()
		
		p1_vel_transfer.emit(old_velocity, angle)
		velocity += difference * scaling
		velocity = velocity.rotated(needed_rotation)
		
		
		
		velocity = velocity * 0.9
	
			
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
	move_and_collide(velocity * 1 * delta)
	rotation = 0
	global.asteroid1_pos = position

