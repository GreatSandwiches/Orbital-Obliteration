extends Area2D
@export var speed = 500
@export var lifetime = 2.0
@onready var global = get_node("/root/Global")
var velocity = Vector2.ZERO
var base_dmg = 20
var shotgun_dmg = 5
var enhanced_shotgun_dmg = 10
var enhanced_bullet_dmg = 40
var shotgun_size = Vector2(0.7, 0.7)
var enhanced_shotgun_size = Vector2(1.4, 1.4)
var enhanced_bullet_size = Vector2(2, 2)
var slow_speed_multiplier = 0.7
var damage = base_dmg
signal p1_hit
signal p2_hit
signal ai_hit


func _ready():
	# Connects necessary signals based on whether ai or player opponent is selected
	if global.game_mode == 1:
		p1_hit.connect(get_node("/root/Level/Player1")._hit)
		p2_hit.connect(get_node("/root/Level/Player2")._hit)
	else:
		p2_hit.connect(get_node("/root/Level/Player2")._hit)
		ai_hit.connect(get_node("/root/Level/EnemyAi")._hit)
	# Calculate the velocity based on the rotation
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	# Sets the bullet speed and damage based on who fired the bullet 
	if self.is_in_group("p1_bullet"):
		damage = global.p1_gundamage
		velocity = velocity * global.p1_bulletspeed
	if self.is_in_group("p2_bullet"):
		damage = global.p2_gundamage
		velocity = velocity * global.p2_bulletspeed
	if self.is_in_group("enemy_bullet"):
		# Damage/speed setting works different for enemy bullets by checking the active powerups
		if global.enemy_damage == true:
			if global.enemy_shotgun == true:
				self.set_scale(enhanced_shotgun_size)
				damage = enhanced_shotgun_size
			else:
				self.set_scale(enhanced_bullet_size)
				damage = enhanced_bullet_dmg
			velocity = velocity * slow_speed_multiplier
		if global.enemy_shotgun == true:
			if global.enemy_damage == false:
				self.set_scale(shotgun_size)
				damage = shotgun_dmg
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
	# Deletes the bullet when it hits certain things, emits damage signal if players/ai is hit
	if area.is_in_group("player1"):
		# Ensures the bullet cannot hit who it was fired by (same for p2 and ai)
		if not self.is_in_group("p1_bullet"):
			# Include velocity of bullet in signal for knockback calculations
			p1_hit.emit(self, velocity, damage)
			queue_free()
	if area.is_in_group("player2"):
		if not self.is_in_group("p2_bullet"):
			p2_hit.emit(self, velocity, damage)
			queue_free()
	if area.is_in_group("ai"):
		if not self.is_in_group("enemy_bullet"):
			ai_hit.emit(self, velocity, damage)
			queue_free()
	if (
			area.is_in_group("space_mine") 
			or area.is_in_group("missile") 
			or area.is_in_group("wall")
	):
		queue_free()

