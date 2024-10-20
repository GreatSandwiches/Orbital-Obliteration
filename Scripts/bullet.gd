extends Area2D

# Constants
const BASE_DAMAGE = 20
const SHOTGUN_DAMAGE = 5
const ENHANCED_SHOTGUN_DAMAGE = 10
const ENHANCED_BULLET_DAMAGE = 40
const SHOTGUN_SIZE = Vector2(0.7, 0.7)
const ENHANCED_SHOTGUN_SIZE = Vector2(1.4, 1.4)
const ENHANCED_BULLET_SIZE = Vector2(2, 2)
const SLOW_SPEED_MULTIPLIER = 0.7

# Exported variables
@export var speed = 500
@export var lifetime = 2.0

# Variables
@onready var global = get_node("/root/Global")
var velocity = Vector2.ZERO
var damage = BASE_DAMAGE

# Signals
signal p1_hit
signal p2_hit
signal ai_hit

func _ready() -> void:
	# Connects necessary signals based on whether AI or player opponent is selected
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
		damage = global.p1_gun_damage
		velocity *= global.p1_bullet_speed
	elif self.is_in_group("p2_bullet"):
		damage = global.p2_gun_damage
		velocity *= global.p2_bullet_speed
	elif self.is_in_group("enemy_bullet"):
		# Damage/speed setting works differently for enemy bullets by checking the active powerups
		if global.enemy_damage:
			if global.enemy_shotgun:
				self.set_scale(ENHANCED_SHOTGUN_SIZE)
				damage = ENHANCED_SHOTGUN_DAMAGE
			else:
				self.set_scale(ENHANCED_BULLET_SIZE)
				damage = ENHANCED_BULLET_DAMAGE
			velocity *= SLOW_SPEED_MULTIPLIER

		if global.enemy_shotgun and not global.enemy_damage:
			self.set_scale(SHOTGUN_SIZE)
			damage = SHOTGUN_DAMAGE

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


func _process(delta: float) -> void:
	# Move the bullet forward in the direction it is facing
	position += velocity * delta


func _on_area_entered(area) -> void:
	# Deletes the bullet when it hits certain objects, emits damage signal if players/AI is hit
	if area.is_in_group("player1"):
		# Ensures the bullet cannot hit who it was fired by (same for p2 and AI)
		if not self.is_in_group("p1_bullet"):
			# Include velocity of bullet in signal for knockback calculations
			p1_hit.emit(self, velocity, damage)
			queue_free()
	elif area.is_in_group("player2"):
		if not self.is_in_group("p2_bullet"):
			p2_hit.emit(self, velocity, damage)
			queue_free()
	elif area.is_in_group("ai"):
		if not self.is_in_group("enemy_bullet"):
			ai_hit.emit(self, velocity, damage)
			queue_free()
	elif (
		area.is_in_group("space_mine") 
		or area.is_in_group("missile") 
		or area.is_in_group("wall")
	):
		queue_free()
