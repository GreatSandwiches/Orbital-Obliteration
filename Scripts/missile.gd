extends Area2D
@export var speed = 200
@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D
var velocity = Vector2.ZERO
var target_position = Vector2(0,0)
var direction = Vector2(0,0)
var speedscale = 1
var turnscale = 1
signal p1_hit
signal p2_hit
signal ai_hit

func _ready():
	if global.game_mode == 1:
		p1_hit.connect(get_node("/root/Level/Player1")._hit)
		p2_hit.connect(get_node("/root/Level/Player2")._hit)
	else:
		p2_hit.connect(get_node("/root/Level/Player2")._hit)
		ai_hit.connect(get_node("/root/Level/EnemyAi")._hit)
		
	# Calculate the velocity based on the rotation
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	# Multiplies velocity by desired bullet speed (for shotgun powerup)
	if self.is_in_group("p1_missile"):
		speedscale = global.p1_bulletspeed
	if self.is_in_group("p2_missile"):
		speedscale = global.p2_bulletspeed
	if self.get_scale() == Vector2(2,2):
		turnscale = 0.7

func _lifetime_timeout():
	print("magic")
	queue_free()
	
func _dissappear():
	$GPUParticles2D.emitting = true
	hitbox.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Trail.hide()
	$Lifetime.start(5)
	#queue_free()

func _process(delta):
	if global.game_mode == 1:
		if self.is_in_group("p1_missile"):
			target_position = global.p2_position
		if self.is_in_group("p2_missile"):
			target_position = global.p1_position
	else:
		target_position = global.ai_position
	
	direction = target_position - position
	var angle = self.transform.x.angle_to(direction)
	self.rotate(sign(angle) * min((PI * turnscale) / 80, abs(angle)))
	
	# Move the bullet forward in the direction it is facing
	velocity = Vector2(cos(rotation), sin(rotation)) * speed * speedscale
	position += velocity * delta
	
func _on_area_entered(area):
	if area.is_in_group("player1"):
		if not self.is_in_group("p1_missile"):
			p1_hit.emit(self, velocity * 16)
			_dissappear()
	if area.is_in_group("player2"):
		if not self.is_in_group("p2_missile"):
			p2_hit.emit(self, velocity * 16)
			_dissappear()
	if area.is_in_group("wall") or area.is_in_group("bullet") or area.is_in_group("space_mine"):
		_dissappear()
	if area.is_in_group("ai"):
		if not self.is_in_group("enemy_missile"):
			print(self.get_scale())
			ai_hit.emit(self, velocity * 16)
			_dissappear()

	
#Knockback and durability implementation?????????????????
#also make reload cooldown super high

