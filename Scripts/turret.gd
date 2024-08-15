extends Node2D


@export var bullet_scene: PackedScene
@onready var global = get_node("/root/Global")
var loaded = true
var direction = Vector2(0,0)

func _ready():
	pass # Replace with function body.

func _shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)

func _cooldown_done():
	loaded = true

func _process(delta):
	var target_position = global.p2_position  # Default to Player 2's position

	if global.game_mode == 1:
		# Search for both players when game_mode is 1
		if $Detection.overlaps_area(get_node("/root/Level/Player1").get_child(0)) or $Detection.overlaps_area(get_node("/root/Level/Player2").get_child(0)):
			if position.distance_to(global.p1_position) <= position.distance_to(global.p2_position):
				target_position = global.p1_position
			else:
				target_position = global.p2_position
	else:
		# Only look for Player 2 when game_mode is 0
		if $Detection.overlaps_area(get_node("/root/Level/Player2").get_child(0)):
			target_position = global.p2_position

	# Calculate direction towards the target position
	direction = target_position - position
	
	# Rotate towards the target direction smoothly
	var angle = self.transform.x.angle_to(direction)
	self.rotate(sign(angle) * min(PI / 70, abs(angle)))

	# Shooting logic
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			if loaded == true:
				_shoot()
				loaded = false
				$Timer.start(1)
