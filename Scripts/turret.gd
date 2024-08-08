extends Node2D


@export var bullet_scene: PackedScene
@onready var global = get_node("/root/Global")

func _ready():
	pass # Replace with function body.

func _shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Detection.overlaps_area(get_node("/root/Level/Player1").get_child(0)):
		rotation = lerp_angle(rotation, (global.p1_position - position).angle(), 0.05)
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			_shoot()
	print($Ray.get_collider())
