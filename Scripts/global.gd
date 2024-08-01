extends Node
# p1 variables
var p1_score = 0
var p1_location = Vector2(0,0)
var p1_health = 100
var p1_gunheat = 0
var p1_maxgunheat = 10
var p1_coolingrate = 3
var p1_firerate = 0.3
var p1_gundamage = 1
var p1_bulletsize = 1
var spacemine_collision_pos_p1 = Vector2(0,0)
var p1_position = Vector2(0,0)
var p1_velocity = Vector2(0,0)
var p1_gundamagepowerup = false

#p2 variables
var p2_score = 0
var p2_location = Vector2(0,0)
var p2_health = 100
var p2_gunheat = 0
var p2_maxgunheat = 10
var p2_coolingrate = 3
var p2_firerate = 0.3
var p2_gundamage = 1
var p2_bulletsize = 1
var spacemine_collision_pos_p2 = Vector2(0,0)
var p2_position = Vector2(0,0)
var p2_velocity = Vector2(0,0)
var p2_gundamagepowerup = false

#Variables
var asteroid1_pos = Vector2(0,0)
var wall_pos1 = Vector2(0,0)



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
