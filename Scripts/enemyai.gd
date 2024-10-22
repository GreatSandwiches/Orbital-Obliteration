extends CharacterBody2D

@onready var global = get_node("/root/Global")
@onready var nav: NavigationAgent2D = $NavigationAgent2D

@export var bullet_scene: PackedScene
@export var missile_scene: PackedScene

# Constants
const SPEED = 180
const ACCEL = 2
const MIN_DISTANCE = 50
const RELOAD_PERIOD_DEFAULT = 0.5
const RELOAD_PERIOD_RAPID_FIRE = 0.2
const KNOCKBACK_MULTIPLIER = 15
const DAMAGE_UP_DURATION = 10
const RAPID_FIRE_DURATION = 10
const SHOTGUN_DURATION = 10
const KO_SCALE_SMALL = 0.06
const KO_SCALE_LARGE = 0.15
const PLAYER_RESPAWN_POSITION = Vector2(120, 150)
const PLAYER_LOW_HEALTH_THRESHOLD = 30
const SHIELD_RESET_FRAME = 0.0
const MINE_DAMAGE = 30
const SHOTGUN_ANGLE_SMALL = PI / 36
const SHOTGUN_ANGLE_LARGE = PI / 7
const HIDING_POSITION = Vector2(-101, 151)
const MAX_HEALTH = 100
const MISSILE_HEAT = 2
const BULLET_HEAT = 0.1
const MISSILE_SCALE = Vector2(0.7, 0.7)

# Variables
var speed = SPEED
var accel = ACCEL
var min_distance = MIN_DISTANCE
var loaded = true
var ko_scale = 0.0
var reload_period = RELOAD_PERIOD_DEFAULT
var missile = 0
var angle_list = []
var knockback = Vector2(0, 0)
var shield = true
var immunity = true
var projectile = null
var powerup_locations = []
var target = Vector2(0, 0)
var target_check = 0
var missile_pwr_location = Vector2(0, 0)
var shotgun_pwr_location = Vector2(0, 0)
var dmg_pwr_location = Vector2(0, 0)
var shield_pwr_location = Vector2(0, 0)
var rapidfire_pwr_location = Vector2(0, 0)
var processed_location = Vector2(0, 0)

# Initialize settings and set up powerup locations based on level
func _ready():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, SHIELD_RESET_FRAME)
	global.enemy_rapid = false
	global.enemy_shotgun = false
	global.enemy_damage = false
	global.ai_health = MAX_HEALTH
	
	if global.selected_level == "res://Scenes/level.tscn":
		powerup_locations = [
			Vector2(194, 327),
			Vector2(210, 455),
			Vector2(392, 556),
			Vector2(594, 315),
			Vector2(751, 204)
		]
		missile_pwr_location = Vector2(194, 327)
		shotgun_pwr_location = Vector2(210, 455)
		dmg_pwr_location = Vector2(392, 556)
		shield_pwr_location = Vector2(594, 315)
		rapidfire_pwr_location = Vector2(751, 204)


# Function to handle shooting projectiles
func _shoot(deviation, type):
	print(bullet_scene)
	if bullet_scene == null:
		print("Error: bullet_scene is not assigned!")
		return
	if missile == 1:
		projectile = missile_scene.instantiate()
	else:
		projectile = bullet_scene.instantiate()
	projectile.position = $ProjectileSpawn.global_position
	projectile.rotation = rotation + deviation
	get_parent().add_child(projectile)


# Reset the loaded state after cooldown
func _cooldown_done():
	loaded = true


# Apply damage to the AI and check if health is depleted
func take_damage(amount):
	global.ai_health -= amount
	print("taking damage")
	if global.ai_health <= 0:
		die()


# Disable shield and immunity
func _shield_down():
	immunity = false


# Reactivate shield and immunity when power-up is collected
func _shield_powerup_collected():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, SHIELD_RESET_FRAME)
	shield = true
	immunity = true


# Enable missile mode when missile power-up is collected
func _missile_powerup_collected():
	missile = 1


# Handle collision with a mine, applying damage or knockback
func _mine_collision():
	if immunity == false:
		take_damage(MINE_DAMAGE)
	else:
		$Shieldframes.play()
		shield = false
	knockback = position - global.space_mine_collision_pos_p1
	velocity += knockback * KNOCKBACK_MULTIPLIER


# Activate damage boost for a set duration
func _damage_up():
	global.enemy_damage = true
	$Damagetimer.start(DAMAGE_UP_DURATION)


# Activate rapid fire mode for a set duration
func _rapid_fire():
	global.enemy_rapid = true
	reload_period = RELOAD_PERIOD_RAPID_FIRE
	$Rapidtimer.start(RAPID_FIRE_DURATION)


# Activate shotgun mode for a set duration
func _shotgun():
	global.enemy_shotgun = true
	$Shotguntimer.start(SHOTGUN_DURATION)


# Deactivate rapid fire mode after timer ends
func _on_rapidtimer_timeout():
	global.enemy_rapid = false
	reload_period = RELOAD_PERIOD_DEFAULT


# Deactivate damage boost after timer ends
func _on_damagetimer_timeout():
	global.enemy_damage = false


# Deactivate shotgun mode after timer ends
func _on_shotguntimer_timeout():
	global.enemy_shotgun = false


# Handle when the AI is hit by a projectile, applying knockback and damage
func _hit(projectile, bullet_vel, damage):
	if shield == true and $Shieldframes.is_playing() == false:
		shield = false
		$Shieldframes.play()
	if immunity == false:
		if projectile.is_in_group("p2_bullet"):
			take_damage(damage)
			velocity += bullet_vel * 0.3 * projectile.get_scale()
		if projectile.is_in_group("p2_missile"):
			take_damage(damage * 2.5)
			if projectile.get_scale() == MISSILE_SCALE:
				ko_scale = KO_SCALE_SMALL
			else:
				ko_scale = KO_SCALE_LARGE
			velocity += bullet_vel * ko_scale * projectile.get_scale()


# Reset AI state after dying
func die():
	global.ai_health = MAX_HEALTH
	global.p2_score += 1
	position = PLAYER_RESPAWN_POSITION
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, SHIELD_RESET_FRAME)
	shield = true
	immunity = true


# Process physics every frame, including AI movement and behaviors
func _physics_process(delta):
	# Hide AI if in game mode 1
	if global.game_mode == 1:
		velocity = Vector2.ZERO
		visible = false
		position = HIDING_POSITION
		return

	visible = true
	global.ai_position = position

	# Emit smoke trail if health is below the threshold
	if global.ai_health < PLAYER_LOW_HEALTH_THRESHOLD:
		$SmokeTrail.emitting = true
	else:
		$SmokeTrail.emitting = false

	target = global.p2_position

	# Adjust target based on powerup visibility
	for location in powerup_locations:
		processed_location = location
		if global.missile_power_hidden == true and location == missile_pwr_location:
			processed_location = global.p2_position
		if global.shotgun_power_hidden == true and location == shotgun_pwr_location:
			processed_location = global.p2_position
		if global.dmg_power_hidden == true and location == dmg_pwr_location:
			processed_location = global.p2_position
		if global.shield_power_hidden == true and location == shield_pwr_location:
			processed_location = global.p2_position
		if global.rapid_power_hidden == true and location == rapidfire_pwr_location:
			processed_location = global.p2_position

		target_check = position.distance_to(processed_location)
		if target_check < position.distance_to(target):
			target = processed_location

	nav.target_position = target

	# Calculate movement direction and speed
	var direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	var distance_to_player = global_position.distance_to(global.p2_position)
	var speed_factor = clamp((distance_to_player - min_distance) / min_distance, 0, 1)

	# Smoothly rotate towards the direction of movement
	if direction != Vector2.ZERO:
		var target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, accel * delta * 2)

	# Adjust velocity based on direction and speed
	velocity = velocity.lerp(direction * speed * speed_factor, accel * delta)

	# Shooting logic
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			if loaded == true:
				if global.enemy_shotgun == true:
					angle_list = [(-2 * SHOTGUN_ANGLE_SMALL),
					 (-1 * SHOTGUN_ANGLE_SMALL),
					 0, (1 * SHOTGUN_ANGLE_SMALL),
					 (2 * SHOTGUN_ANGLE_SMALL)]
					if missile == 1:
						angle_list = [(-2 * SHOTGUN_ANGLE_LARGE),
						 (-1 * SHOTGUN_ANGLE_LARGE),
						 0, (1 * SHOTGUN_ANGLE_LARGE),
						 (2 * SHOTGUN_ANGLE_LARGE)]
					for deviation in angle_list:
						if missile == 1:
							_shoot(deviation, "missile")
							global.p1_gun_heat += MISSILE_HEAT
						else:
							_shoot(deviation, "bullet")
							global.p1_gun_heat += BULLET_HEAT
				else:
					if missile == 1:
						_shoot(0, "missile")
					else:
						_shoot(0, "bullet")
				loaded = false
				missile = 0
				$Timer.start(reload_period)

	move_and_slide()
