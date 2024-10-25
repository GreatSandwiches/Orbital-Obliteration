extends Area2D

# Constants
const ROTATION_SPEED_BASE = PI / 80  
const DAMAGE_SMALL = 5  
const DAMAGE_LARGE = 10  
const DAMAGE_EXTRA_LARGE = 40  
const MISSILE_SPEED_SCALE = 0.7  
const TURN_SCALE_LARGE_MISSILE = 0.7  
const LARGE_MISSILE_SCALE = Vector2(2, 2)  
const SMALL_MISSILE_SCALE = Vector2(0.7, 0.7)  
const EXTRA_LARGE_MISSILE_SCALE = Vector2(1.4, 1.4)  
const LIFETIME_DURATION = 5  
const KNOCKBACK_MULTIPLIER = 16  

@export var speed = 200  # Base speed of the missile
@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D

# Variables
var velocity = Vector2.ZERO  
var target_position = Vector2(0, 0)  
var direction = Vector2(0, 0)  
var speed_scale = 1  
var turn_scale = 1  
var damage = 0  

# Signals for interactions with players and AI
signal p1_hit
signal p2_hit
signal ai_hit

# Initialization and setup
func _ready():
	# Connect hit signals based on the game mode and target
	if global.game_mode == 1:
		# Multiplayer mode: connect P1 and P2 hits
		p1_hit.connect(get_node("/root/Level/Player1")._hit)
		p2_hit.connect(get_node("/root/Level/Player2")._hit)
	else:
		# Singleplayer mode: connect P2 and AI hits
		p2_hit.connect(get_node("/root/Level/Player2")._hit)
		ai_hit.connect(get_node("/root/Level/EnemyAi")._hit)
		
	# Calculate the initial velocity based on the current rotation
	velocity = Vector2(cos(rotation), sin(rotation)) * speed

	# Adjust missile settings based on group membership
	if self.is_in_group("p1_missile"):
		# Settings for player 1's missiles
		damage = global.p1_gun_damage
		speed_scale = global.p1_bullet_speed
	elif self.is_in_group("p2_missile"):
		# Settings for player 2's missiles
		damage = global.p2_gun_damage
		speed_scale = global.p2_bullet_speed
	elif self.is_in_group("enemy_missile"):
		# Settings for enemy missiles based on power-up effects
		if global.enemy_damage:
			if global.enemy_shotgun:
				self.set_scale(EXTRA_LARGE_MISSILE_SCALE)
				damage = DAMAGE_LARGE
			else:
				self.set_scale(LARGE_MISSILE_SCALE)
				damage = DAMAGE_EXTRA_LARGE
			velocity *= MISSILE_SPEED_SCALE
		
		# If only the shotgun effect is active
		if global.enemy_shotgun and not global.enemy_damage:
			self.set_scale(SMALL_MISSILE_SCALE)
			damage = DAMAGE_SMALL

	# Adjust turn scale for large missiles
	if self.get_scale() == LARGE_MISSILE_SCALE:
		turn_scale = TURN_SCALE_LARGE_MISSILE


# Handles the lifetime of the missile, destroying it after a set period
func _lifetime_timeout():
	# Remove the missile after a set duration
	queue_free()


# Makes the missile disappear, triggering visual effects and hiding elements
func _dissappear():
	# Activate particle effects and disable collision
	$Explosion.emitting = true
	hitbox.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Trail.hide()
	$Lifetime.start(LIFETIME_DURATION)


# Processes the missile's movement and rotation every frame
func _process(delta):
	# Determine the target position based on game mode and missile type
	if global.game_mode == 1:
		if self.is_in_group("p1_missile"):
			target_position = global.p2_position
		elif self.is_in_group("p2_missile"):
			target_position = global.p1_position
	else:
		if self.is_in_group("enemy_missile"):
			target_position = global.p2_position
		else:
			target_position = global.ai_position

	# Rotate towards the target and adjust velocity
	direction = target_position - position
	var angle = self.transform.x.angle_to(direction)
	# Smoothly adjust the missile's rotation to face the target
	self.rotate(sign(angle) * min(ROTATION_SPEED_BASE * turn_scale, abs(angle)))

	# Update the missile's velocity and position
	velocity = Vector2(cos(rotation), sin(rotation)) * speed * speed_scale
	position += velocity * delta


# Handles collision detection and interaction with different areas
func _on_area_entered(area):
	# Check if the missile hits player 1 and wasn't fired by player 1
	if area.is_in_group("player1") and not self.is_in_group("p1_missile"):
		p1_hit.emit(self, velocity * KNOCKBACK_MULTIPLIER, damage)
		_dissappear()
	# Check if the missile hits player 2 and wasn't fired by player 2
	elif area.is_in_group("player2") and not self.is_in_group("p2_missile"):
		p2_hit.emit(self, velocity * KNOCKBACK_MULTIPLIER, damage)
		_dissappear()
	# Disappear when hitting a wall or a space mine
	elif area.is_in_group("wall") or area.is_in_group("space_mine"):
		_dissappear()
	# Check for bullet collision
	elif area.is_in_group("bullet"):
		if area.is_in_group("enemy_bullet") and not self.is_in_group("enemy_missile"):
			_dissappear()
		else:
			_dissappear()
	# Check if the missile hits the AI and wasn't fired by the AI
	elif area.is_in_group("ai") and not self.is_in_group("enemy_missile"):
		ai_hit.emit(self, velocity * KNOCKBACK_MULTIPLIER, damage)
		_dissappear()
