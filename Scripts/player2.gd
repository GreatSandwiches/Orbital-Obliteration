extends CharacterBody2D

@onready var global = get_node("/root/Global")

# Constants for player mechanics and powerups
const BASE_SPEED = 10000
const ROTATION_SPEED = 0.075
const ACCELERATION_AMOUNT = 2
const KNOCKBACK_SCALING = 0.0005
const MISSILE_DAMAGE_MULTIPLIER = 2.5
const MINE_KNOCKBACK = 0.07
const MINE_DAMAGE = 30
const SHOTGUN_POWERUP_DURATION = 10
const RAPID_FIRE_RATE = 0.1
const RAPID_COOLING_RATE = 8
const RAPID_FIRE_DURATION = 10
const DAMAGE_BOOST_DURATION = 10
const OVERHEAT_THRESHOLD = 10
const BIG_BULLET_SCALING = Vector2(2, 2)
const ENHANCED_SHOTGUN_SCALING = Vector2(1.4, 1.4)
const SMALL_BULLET_SCALING = Vector2(0.7, 0.7)
const DEFAULT_FIRE_RATE = 0.3
const DEFAULT_COOLING_RATE = 3
const PLAYER_STARTING_HEALTH = 100
const SHIP_VECTOR_BACKWARD_FACTOR = 0.01
const SHIP_VECTOR_BACKWARD_OFFSET = 1.2
const VELOCITY_SCALING = 400
const OVERHEAT_TIMER_DURATION = 1
const BASE_DAMAGE = 20
const SHOTGUN_DAMAGE = 5
const MISSILE_ACTIVATED = 1
const BIG_BULLET_SPEED = 0.7
const SHOTGUN_BULLET_SPEED = 1
const SPAWN_POSITION = Vector2(1020, 500)
const SCORE_INCREMENT_AMOUNT = 1
const ROTATION_MULTIPLIER = 0.25
const BIG_BULLET_DAMAGE_MULT = 2
const SHOTGUN_ANGLE_STEP_SMALL = PI / 36
const SHOTGUN_ANGLE_STEP_LARGE = PI / 7
const BULLET_HEAT_INCREMENT = 0.1
const MISSILE_HEAT_INCREMENT = 2
const MISSILE_ACTIVE = 1
const SPACESHIP_SMOKING = 30
const TRAIL_OFFSET = -10


# Variables for player status and powerup states
var speed = BASE_SPEED
var acceleration = 0
var target_rotation = PI
var ship_vector = Vector2.ZERO
var ship_vector_forward = Vector2.ZERO
var ship_vector_backward = Vector2.ZERO
@export var bullet_p2_scene: PackedScene
@export var missile_p2_scene: PackedScene
var can_shoot = true
@onready var p2 = $Player2
var knockback = Vector2.ZERO
var score = 0
var can_cool = true
var is_overheated = false
var shotgun = false
var base_gun_damage = 20
var big_bullet = false
var shield = true
var immunity = true
var missile = 0
var angle_list = []


# Signals for game UI updates and animations
signal shield_animation
signal powered_up


# Initialization function to set up default values and connect signals
func _ready():
	# Reset shield visuals and connect powerup signal to UI
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, 0.0)
	global.p2_gun_damage_power_up = false
	global.p2_health = PLAYER_STARTING_HEALTH
	global.p2_gun_heat = 0
	global.p2_fire_rate = DEFAULT_FIRE_RATE
	global.p2_gun_damage = base_gun_damage
	global.p2_cooling_rate = DEFAULT_COOLING_RATE
	$Timer.wait_time = global.p2_fire_rate
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Area2D/SmokeTrail.emitting = false
	powered_up.connect(get_node("/root/Level/P2_UI")._powered_up)


# Handles taking damage from various types of projectiles and applying knockback
func _hit(projectile, bullet_vel, damage):
	if shield and !$Shieldframes.is_playing():
		# Activate shield if it is available and not currently active
		shield = false
		$Shieldframes.play()
	if !immunity:
		# Apply damage and knockback based on projectile type
		if projectile.is_in_group("p1_bullet"):
			take_damage(damage)
			ship_vector += bullet_vel * KNOCKBACK_SCALING * projectile.get_scale()
		elif projectile.is_in_group("p1_missile"):
			take_damage(damage * MISSILE_DAMAGE_MULTIPLIER)
			ship_vector += bullet_vel * KNOCKBACK_SCALING * projectile.get_scale()
		elif projectile.is_in_group("enemy_bullet"):
			take_damage(damage)
			ship_vector += bullet_vel * KNOCKBACK_SCALING * projectile.get_scale()
		elif projectile.is_in_group("enemy_missile"):
			take_damage(damage * MISSILE_DAMAGE_MULTIPLIER)
			ship_vector += bullet_vel * KNOCKBACK_SCALING * projectile.get_scale()


# Disables the shield and removes immunity when shield power is depleted
func _shield_down():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(1, 0.0)
	immunity = false


# Re-enables shield and immunity when a shield powerup is collected
func _shield_powerup_collected():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, 0.0)
	shield = true
	immunity = true


# Activates the missile powerup, allowing player to fire missiles
func _missile_powerup_collected():
	missile = MISSILE_ACTIVATED


# Enables shotgun powerup effects for a limited duration
func _shotgun_powerup_collected():
	base_gun_damage = SHOTGUN_DAMAGE
	shotgun = true
	$ShotgunTimer.start(SHOTGUN_POWERUP_DURATION)
	powered_up.emit()


# Resets shotgun powerup effects when the timer ends
func _on_shotgun_timer_timeout():
	base_gun_damage = BASE_DAMAGE
	shotgun = false


# Handles rapid-fire powerup effects, increasing fire rate and cooling
func _on_rapidfire_entered(area):
	if area.has_meta("rapidfire"):
		global.p2_fire_rate = RAPID_FIRE_RATE
		global.p2_cooling_rate = RAPID_COOLING_RATE
		$RapidFireTimer.start(RAPID_FIRE_DURATION)
		powered_up.emit()


# Resets fire rate and cooling rate after rapid-fire powerup duration ends
func _on_RapidFireTimer_timeout():
	global.p2_fire_rate = DEFAULT_FIRE_RATE
	global.p2_cooling_rate = DEFAULT_COOLING_RATE
	$Timer.wait_time = global.p2_fire_rate


# Activates damage boost powerup effects, enabling larger bullets
func _on_damagepowerup_entered(area):
	if area.has_meta("damageincrease"):
		$DamageBoostTimer.start(DAMAGE_BOOST_DURATION)
		big_bullet = true
		powered_up.emit()


# Disables damage boost effects after timer ends
func _on_DamagePowerupTimer_timeout():
	big_bullet = false


# Reduces player health when taking damage; triggers death if health reaches 0
func take_damage(amount):
	global.p2_health -= amount
	if global.p2_health <= 0:
		die()


# Applies knockback and damage upon collision with mines
func _mine_collision():
	knockback = (position - global.space_mine_collision_pos_p2)
	ship_vector += knockback * MINE_KNOCKBACK
	if !immunity:
		take_damage(MINE_DAMAGE)
	else:
		$Shieldframes.play()
		shield = false


# Resets player state and position when they die
func die():
	$Area2D/SmokeTrail.emitting = false
	global.p2_health = PLAYER_STARTING_HEALTH
	global.p1_score += SCORE_INCREMENT_AMOUNT
	global.p2_gun_heat = 0
	position = SPAWN_POSITION
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, 0.0)
	shield = true
	immunity = true
	ship_vector = Vector2.ZERO


# Manages bullet and missile shooting, including powerup effects
func _shoot(deviation, type):
	var bullet = bullet_p2_scene.instantiate()
	var missile = missile_p2_scene.instantiate()
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	missile.position = $ProjectileSpawn.global_position
	missile.rotation = rotation + deviation

	# Adjusts bullet and missile scaling based on active powerups
	if big_bullet:
		if shotgun:
			bullet.set_scale(ENHANCED_SHOTGUN_SCALING)
			missile.set_scale(ENHANCED_SHOTGUN_SCALING)
		else:
			bullet.set_scale(BIG_BULLET_SCALING)
			missile.set_scale(BIG_BULLET_SCALING)
		global.p2_gun_damage = base_gun_damage * BIG_BULLET_DAMAGE_MULT
		global.p2_bullet_speed = BIG_BULLET_SPEED
	else:
		if shotgun:
			bullet.set_scale(SMALL_BULLET_SCALING)
			missile.set_scale(SMALL_BULLET_SCALING)
		global.p2_bullet_speed = SHOTGUN_BULLET_SPEED
		global.p2_gun_damage = base_gun_damage

	if type == "missile":
		get_parent().add_child(missile)
	if type == "bullet":
		get_parent().add_child(bullet)


# Resets the ability to shoot after a brief cooldown
func _on_timer_timeout():
	can_shoot = true


# Adjusts ship velocity when colliding with asteroids
func _ast_vel_transfer(amount):
	ship_vector -= amount


# Resets overheating status after cooldown period
func _on_overheat_timer_timeout():
	is_overheated = false
	can_shoot = true


# Manages player movement, shooting mechanics, and powerup interactions each frame
func _physics_process(delta):
	global.p2_position = position
	global.p2_velocity = ship_vector
	position.x = clamp(position.x, CameraLimits.limit_left, CameraLimits.limit_right)
	position.y = clamp(position.y, CameraLimits.limit_top, CameraLimits.limit_bottom)

	# Calculates forward and backward ship movement
	ship_vector_forward = Vector2(transform.x * acceleration * delta)
	ship_vector += ship_vector_forward - ship_vector_backward

	# Applies gradual deceleration based on direction of movement
	if ship_vector.x >= 0:
		ship_vector_backward.x = SHIP_VECTOR_BACKWARD_FACTOR * (pow((ship_vector.x + SHIP_VECTOR_BACKWARD_OFFSET), 3) - 1.728)
	elif ship_vector.x <= 0:
		ship_vector_backward.x = SHIP_VECTOR_BACKWARD_FACTOR * (pow((ship_vector.x - SHIP_VECTOR_BACKWARD_OFFSET), 3) + 1.728)
	if ship_vector.y >= 0:
		ship_vector_backward.y = SHIP_VECTOR_BACKWARD_FACTOR * (pow((ship_vector.y + SHIP_VECTOR_BACKWARD_OFFSET), 3) - 1.728)
	elif ship_vector.y <= 0:
		ship_vector_backward.y = SHIP_VECTOR_BACKWARD_FACTOR * (pow((ship_vector.y - SHIP_VECTOR_BACKWARD_OFFSET), 3) + 1.728)

	velocity = VELOCITY_SCALING * ship_vector

	# Handles cooling of the player's weapon system
	if global.p2_gun_heat > 0 and can_cool:
		global.p2_gun_heat -= global.p2_cooling_rate * delta
		if global.p2_gun_heat < 0:
			global.p2_gun_heat = 0

	# Checks for player actions to control movement, rotation, and shooting
	global.p2_location = TRAIL_OFFSET * transform.x + position
	if global.p2_health < SPACESHIP_SMOKING:
		$Area2D/SmokeTrail.emitting = true

	if Input.is_action_pressed("ui_up"):
		acceleration = ACCELERATION_AMOUNT
	else:
		acceleration = 0

	if Input.is_action_pressed("ui_left"):
		target_rotation -= ROTATION_SPEED
	elif Input.is_action_pressed("ui_right"):
		target_rotation += ROTATION_SPEED

	rotation = lerp_angle(rotation, target_rotation, ROTATION_MULTIPLIER)

	# Handles player shooting, accounting for overheating and powerups
	if Input.is_action_pressed("ui_spacebar") and can_shoot and !is_overheated:
		if global.p2_gun_heat < global.p2_max_gun_heat:
			if shotgun:
				angle_list = [
					(-2 * SHOTGUN_ANGLE_STEP_SMALL), 
					(-1 * SHOTGUN_ANGLE_STEP_SMALL), 
					0, 
					(1 * SHOTGUN_ANGLE_STEP_SMALL), 
					(2 * SHOTGUN_ANGLE_STEP_SMALL)
				]
				if missile == MISSILE_ACTIVE:
					angle_list = [
					(-2 * SHOTGUN_ANGLE_STEP_LARGE), 
					(-1 * SHOTGUN_ANGLE_STEP_LARGE), 
					0, 
					(1 * SHOTGUN_ANGLE_STEP_LARGE), 
					(2 * SHOTGUN_ANGLE_STEP_LARGE)
				]
				for deviation in angle_list:
					if missile == MISSILE_ACTIVE:
						_shoot(deviation, "missile")
						global.p2_gun_heat += MISSILE_HEAT_INCREMENT
					else:
						_shoot(deviation, "bullet")
						global.p2_gun_heat += BULLET_HEAT_INCREMENT
			else:
				if missile == MISSILE_ACTIVE:
					_shoot(0, "missile")
				else:
					_shoot(0, "bullet")
			missile = 0
			global.p2_gun_heat += MISSILE_HEAT_INCREMENT
			can_shoot = false
			$Timer.start(global.p2_fire_rate)
		else:
			is_overheated = true
			global.p2_gun_heat = OVERHEAT_THRESHOLD
			can_shoot = false
			$OverheatTimer.start(OVERHEAT_TIMER_DURATION)

	move_and_slide()
