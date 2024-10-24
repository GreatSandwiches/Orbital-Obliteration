extends CharacterBody2D

@onready var global = get_node("/root/Global")

# Constants
const SPEED = 10000
const ACCELERATION = 0
const TARGET_ROTATION = 0
const INITIAL_SHIP_VECTOR = Vector2(0, 0)
const INITIAL_BULLET_SPEED = 1
const SLOWED_BULLET_SPEED = 0.7
const BASE_GUN_DAMAGE = 20
const MAX_HEALTH = 100
const DEFAULT_FIRE_RATE = 0.3
const DEFAULT_COOLING_RATE = 3
const OVERHEATED_VALUE = 10
const ROTATION_AMOUNT = 0.075
const MINE_DAMAGE = 30
const KNOCKBACK_AMOUNT = 0.0005
const RAPID_FIRE_RATE = 0.1
const RAPID_COOLING_RATE = 8
const LOW_HEALTH_THRESHOLD = 30
const BIG_BULLET_DAMAGE_MULTIPLIER = 2
const POWERUP_DURATION = 10  # 10 seconds
const MINIMIZE_VELOCITY = 400
const DEFAULT_POSITION = Vector2(120, 150)
const SHIP_VELOCITY_COEFFICIENT = 0.01
const SHIP_FRICTION_THRESHOLD = 1.2
const SHIP_FRICTION_CONSTANT = 1.728
const SHOTGUN_BULLET_COUNT = 5
const MISSILE_ACTIVE = 1
const MISSILE_INACTIVE = 0
const SHOTGUN_DAMAGE = 5
const MINE_KNOCKBACK = 0.07
const MISSILE_DAMAGE = 2.5
const SCORE_INCREMENT = 1
const HIDDEN_POSITION = Vector2(-101, 151)
const ACCELERATION_AMOUNT = 2
const ROTATION_MULTIPLIER = 1
const SHOTGUN_ANGLE_STEP_SMALL = PI / 36
const SHOTGUN_ANGLE_STEP_LARGE = PI / 7
const BULLET_HEAT_INCREMENT = 0.1
const MISSILE_HEAT_INCREMENT = 2
const OVERHEAT_DURATION = 1 # 1 Second
const SHOT_COOLDOWN = 0.5 # 0.5 Seconds
const TRAIL_OFFSET = -10

# Movement variables
var speed = SPEED
var acceleration = ACCELERATION
var target_rotation = TARGET_ROTATION
var ship_vector = INITIAL_SHIP_VECTOR
var ship_vector_forward = INITIAL_SHIP_VECTOR
var ship_vector_backward = INITIAL_SHIP_VECTOR

@export var bullet_p1_scene: PackedScene
@export var missile_p1_scene: PackedScene

# Shooting and scoring variables
var can_shoot = true
var shoot_cooldown = SHOT_COOLDOWN
var score = 0
var can_cool = true

# Knockback variables
var knockback = INITIAL_SHIP_VECTOR
var bullet_knockback = INITIAL_SHIP_VECTOR

# Overheat and weapon status
var is_overheated = false
var big_bullet = false
var shotgun = false

# Gun damage and shield settings
var shield = true
var immunity = true
var missile = MISSILE_INACTIVE
var angle_list = []

# Health and power-up settings
var base_gun_damage = BASE_GUN_DAMAGE
var default_fire_rate = DEFAULT_FIRE_RATE
var default_cooling_rate = DEFAULT_COOLING_RATE
var overheated = OVERHEATED_VALUE
var regular_bullet_speed = INITIAL_BULLET_SPEED
var slowed_bullet_speed = SLOWED_BULLET_SPEED
var starting_position = DEFAULT_POSITION
var enhanced_shotgun_size = Vector2(1.4, 1.4)
var big_bullet_size = Vector2(2, 2)
var shotgun_bullet_size = Vector2(0.7, 0.7)
var missile_damage = MISSILE_DAMAGE
var mine_knockback = MINE_KNOCKBACK

signal shield_animation
signal powered_up


# Called when the node enters the scene tree for the first time.
func _ready():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, 0.0)
	
	# Setting variables to default values
	global.p1_health = MAX_HEALTH
	global.p1_gun_heat = 0
	global.p1_fire_rate = default_fire_rate
	global.p1_gun_damage = base_gun_damage
	global.p1_cooling_rate = default_cooling_rate
	global.p1_bullet_speed = regular_bullet_speed
	global.p1_max_gun_heat = overheated
	$Timer.wait_time = shoot_cooldown
	$Timer.one_shot = true
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	powered_up.connect(get_node("/root/Level/P1_UI")._powered_up)


# Bullet damage and knockback calculation
func _hit(projectile, bullet_vel, damage):
	if shield == true and !$Shieldframes.is_playing():
		shield = false
		$Shieldframes.play()
	
	if immunity == false:
		# Check for bullet type and apply damage and knockback
		if projectile.is_in_group("p2_bullet"):
			take_damage(damage)
			ship_vector += (bullet_vel * KNOCKBACK_AMOUNT * projectile.get_scale())
		
		if projectile.is_in_group("p2_missile"):
			take_damage(damage * missile_damage)
			ship_vector += (bullet_vel * KNOCKBACK_AMOUNT * projectile.get_scale())
		
		if projectile.is_in_group("enemy_bullet"):
			take_damage(damage)
			ship_vector += (bullet_vel * KNOCKBACK_AMOUNT * projectile.get_scale())
		
		if projectile.is_in_group("enemy_missile"):
			take_damage(damage * missile_damage)
			ship_vector += (bullet_vel * KNOCKBACK_AMOUNT * projectile.get_scale())


# Removes immunity when player shield runs out
func _shield_down():
	immunity = false


# Applies shield effect when shield powerup is collected
func _shield_powerup_collected():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, 0.0)
	shield = true
	immunity = true


# Activates the missile when missile powerup is collected
func _missile_powerup_collected():
	missile = MISSILE_ACTIVE  # Activates the missile


# Calculates damage taken and checks if player should die
func take_damage(amount):
	global.p1_health -= amount
	if global.p1_health <= 0:
		die()


# Damages and calculates knockback when player hits a space mine
func _mine_collision():
	knockback = (position - global.space_mine_collision_pos_p1)
	ship_vector += knockback * mine_knockback
	
	if immunity == false:
		take_damage(MINE_DAMAGE)
	else:
		$Shieldframes.play()
		shield = false


# Resets and respawns player when they die
func die():
	global.p1_health = MAX_HEALTH
	global.p2_score += SCORE_INCREMENT
	global.p1_gun_heat = 0
	position = starting_position
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, 0.0)
	shield = true
	immunity = true
	ship_vector = INITIAL_SHIP_VECTOR
	

# Function to handle shooting of bullets
func _shoot(deviation, type):
	var bullet = bullet_p1_scene.instantiate()
	@warning_ignore("shadowed_variable")
	var missile = missile_p1_scene.instantiate()
	
	bullet.position = $ProjectileSpawn.global_position
	bullet.rotation = rotation + deviation
	missile.position = $ProjectileSpawn.global_position
	missile.rotation = rotation + deviation
	
	# Handling of different powerup scenarios
	if big_bullet == true:
		if shotgun == true:
			bullet.set_scale(enhanced_shotgun_size)
			missile.set_scale(enhanced_shotgun_size)
		else:
			bullet.set_scale(big_bullet_size)
			missile.set_scale(big_bullet_size)
		global.p1_gun_damage = base_gun_damage * BIG_BULLET_DAMAGE_MULTIPLIER  # Doubling damage
		global.p1_bullet_speed = slowed_bullet_speed
		
	else:
		if shotgun == true:
			bullet.set_scale(shotgun_bullet_size)
			missile.set_scale(shotgun_bullet_size)
		global.p1_bullet_speed = regular_bullet_speed
		global.p1_gun_damage = base_gun_damage

	if type == "missile":
		get_parent().add_child(missile)
		
	if type == "bullet":
		get_parent().add_child(bullet)
		
	print(global.p1_gun_damage)
	
	
# Function to activate the shotgun when powerup is collected
func _shotgun_powerup_collected():
	base_gun_damage = SHOTGUN_DAMAGE
	shotgun = true
	$ShotgunTimer.start(POWERUP_DURATION)  
	powered_up.emit()
	

# Removes the effects of the shotgun when the powerup runs out
func _on_shotgun_timer_timeout():
	base_gun_damage = BASE_GUN_DAMAGE
	shotgun = false


# Function to handle the rapid-fire power-up
func _on_rapidfire_entered(area):
	if area.has_meta("rapidfire"):
		global.p1_fire_rate = RAPID_FIRE_RATE
		global.p1_cooling_rate = RAPID_COOLING_RATE
		print("Power-up triggered")
		print(global.p1_fire_rate)
		
		# Start the RapidFireTimer
		$RapidFireTimer.start(POWERUP_DURATION) 
		powered_up.emit()


# Resets the fire rate and cooling rate after the timer ends
func _on_RapidFireTimer_timeout():
	global.p1_fire_rate = default_fire_rate   
	global.p1_cooling_rate = default_cooling_rate  
	print("Power-up ended")
	print(global.p1_fire_rate)


# Activates the damage power-up
func _on_damagepowerup_entered(area):
	if area.has_meta("damageincrease"):
		$DamageBoostTimer.start(POWERUP_DURATION)
		big_bullet = true
		powered_up.emit()


# Deactivates the damage powerup when the timer runs out
func _on_DamagePowerupTimer_timeout():
	big_bullet = false


# Timer controlling fire rate
func _on_timer_timeout():
	can_shoot = true


# Allows player to shoot once the gun is no longer overheated
func _on_overheat_timer_timeout():
	is_overheated = false
	can_shoot = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If game mode is singleplayer, player1 will not show
	if global.game_mode == 0:
		visible = false
		velocity = INITIAL_SHIP_VECTOR
		position = HIDDEN_POSITION
		queue_free()
		return
		
	# Added to prevent the health from exceeding the max health
	if global.p1_health > MAX_HEALTH:
		global.p1_health = MAX_HEALTH
		
	# Updating global position and velocity constantly
	global.p1_position = position
	global.p1_velocity = velocity
	
	# Constrain the player's position within the camera limits
	position.x = clamp(position.x, CameraLimits.limit_left, CameraLimits.limit_right)
	position.y = clamp(position.y, CameraLimits.limit_top, CameraLimits.limit_bottom)

	# Outputs ship velocity by adding acceleration subtracted by friction
	ship_vector_forward = Vector2(transform.x * acceleration * delta)
	ship_vector += ship_vector_forward - ship_vector_backward
	
	# Calculates friction vector based on ship velocity
	if ship_vector.x >= 0: 
		ship_vector_backward.x = (
				SHIP_VELOCITY_COEFFICIENT 
				* (pow((ship_vector.x + SHIP_FRICTION_THRESHOLD), 3) 
				- SHIP_FRICTION_CONSTANT)
		)
		
	if ship_vector.x <= 0:
		ship_vector_backward.x = (
			SHIP_VELOCITY_COEFFICIENT 
			* (pow((ship_vector.x - SHIP_FRICTION_THRESHOLD), 3) 
			+ SHIP_FRICTION_CONSTANT)
		)
		
	if ship_vector.y >= 0:
		ship_vector_backward.y = (SHIP_VELOCITY_COEFFICIENT 
			* (pow((ship_vector.y + SHIP_FRICTION_THRESHOLD), 3) 
			- SHIP_FRICTION_CONSTANT)
		)
	
	if ship_vector.y <= 0:
		ship_vector_backward.y = (SHIP_VELOCITY_COEFFICIENT 
			* (pow((ship_vector.y - SHIP_FRICTION_THRESHOLD), 3) 
			+ SHIP_FRICTION_CONSTANT)
		)
		
	# Current position identifier for use with trail
	global.p1_location = TRAIL_OFFSET * transform.x + position
	velocity = MINIMIZE_VELOCITY * ship_vector
	
	# Smoke trail activation based on health
	if global.p1_health < LOW_HEALTH_THRESHOLD:
		$Area2D/SmokeTrail.emitting = true
	else:
		$Area2D/SmokeTrail.emitting = false
	
	# Heat cooldown functionality
	if global.p1_gun_heat > 0 and can_cool:
		global.p1_gun_heat -= global.p1_cooling_rate * delta
		if global.p1_gun_heat < 0:
			global.p1_gun_heat = 0
	
	# Shot detection for gun cooldown
	if Input.is_action_pressed("ui_shift"):
		can_cool = true
	else:
		can_cool = true
	
	# Movement input handling
	if Input.is_action_pressed("ui_w"):
		acceleration = ACCELERATION_AMOUNT
	else:
		acceleration = 0
	
	# Rotation input handling
	if Input.is_action_pressed("ui_a"):
		target_rotation -= ROTATION_AMOUNT
	elif Input.is_action_pressed("ui_d"):
		target_rotation += ROTATION_AMOUNT

	# Smooth rotation using lerp_angle
	rotation = lerp_angle(rotation, target_rotation, ROTATION_MULTIPLIER)
	
	# Detecting if the player can shoot when the key is pressed
	if Input.is_action_pressed("ui_shift") and can_shoot and not is_overheated:
		if global.p1_gun_heat < global.p1_max_gun_heat:
			# Code for generating shotgun bullets
			if shotgun == true: # Angle shotgun pellets are released at
				angle_list = [(-2 * SHOTGUN_ANGLE_STEP_SMALL), 
				 (-1 * SHOTGUN_ANGLE_STEP_SMALL),
				 0,(1 * SHOTGUN_ANGLE_STEP_SMALL),
				 (2 * SHOTGUN_ANGLE_STEP_SMALL)]
				if missile == MISSILE_ACTIVE: # Shooting angle when shotgun and missile are engaged
					angle_list = [(-2 * SHOTGUN_ANGLE_STEP_LARGE),
					 (-1 * SHOTGUN_ANGLE_STEP_LARGE),
					 0,(1 * SHOTGUN_ANGLE_STEP_LARGE),
					 (2 * SHOTGUN_ANGLE_STEP_LARGE)]
				for deviation in angle_list:
					if missile == MISSILE_ACTIVE:
						_shoot(deviation, "missile")
						# Heat buildup when missile is active
						global.p1_gun_heat += MISSILE_HEAT_INCREMENT 
					else:
						_shoot(deviation, "bullet")
						global.p1_gun_heat += BULLET_HEAT_INCREMENT # Normal heat buildup
			else:	
				if missile == MISSILE_ACTIVE:
					_shoot(0, "missile")
				else:
					_shoot(0, "bullet")
			missile = MISSILE_INACTIVE
			global.p1_gun_heat += MISSILE_HEAT_INCREMENT
			can_shoot = false
			$Timer.start(global.p1_fire_rate)
		else:
			# If gun is overheated, prevents shooting
			is_overheated = true
			global.p1_gun_heat = overheated
			can_shoot = false
			$OverheatTimer.start(OVERHEAT_DURATION)

	# Apply velocity and move the character
	move_and_slide()
