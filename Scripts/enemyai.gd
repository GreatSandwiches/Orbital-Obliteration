extends CharacterBody2D

@onready var global = get_node("/root/Global")
@onready var nav: NavigationAgent2D = $NavigationAgent2D

@export var bullet_scene: PackedScene
@export var missile_scene: PackedScene

# Constants
const SPEED = 150
const ACCEL = 2
const MIN_DISTANCE = 50
const RELOAD_PERIOD_DEFAULT = 0.6
const RELOAD_PERIOD_RAPID_FIRE = 0.3
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

# Enhanced AI behavior variables
enum AIBehaviorState { AGGRESSIVE, DEFENSIVE, POWERUP_SEEKING, EVASIVE }
var ai_state = AIBehaviorState.AGGRESSIVE
var state_timer = 0.0
var state_duration = 3.0
var evasion_direction = Vector2.ZERO
var last_player_position = Vector2.ZERO
var player_velocity_prediction = Vector2.ZERO
var consecutive_defeats = 0
var difficulty_modifier = 1.0

# Initialize settings and set up powerup locations based on level
func _ready():
	$Shieldframes.stop()
	$Shieldframes.set_frame_and_progress(0, SHIELD_RESET_FRAME)
	global.enemy_rapid = false
	global.enemy_shotgun = false
	global.enemy_damage = false
	global.ai_health = MAX_HEALTH
	global.ai_permanently_defeated = false
	
	# Initialize AI behavior
	ai_state = AIBehaviorState.AGGRESSIVE
	state_timer = 0.0
	state_duration = randf_range(2.0, 4.0)
	consecutive_defeats = 0
	difficulty_modifier = 1.0
	last_player_position = Vector2.ZERO
	
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


# Function to handle shooting projectiles with improved accuracy
func _shoot(deviation, type):
	print(bullet_scene)
	if bullet_scene == null:
		print("Error: bullet_scene is not assigned!")
		return
	
	# Add some shooting inaccuracy to make AI more realistic
	var accuracy_modifier = 0.0
	match ai_state:
		AIBehaviorState.AGGRESSIVE:
			accuracy_modifier = randf_range(-0.05, 0.05)  # High accuracy
		AIBehaviorState.DEFENSIVE:
			accuracy_modifier = randf_range(-0.1, 0.1)   # Medium accuracy
		AIBehaviorState.EVASIVE:
			accuracy_modifier = randf_range(-0.15, 0.15) # Lower accuracy while evading
		AIBehaviorState.POWERUP_SEEKING:
			accuracy_modifier = randf_range(-0.08, 0.08) # Medium accuracy
	
	if missile == 1:
		projectile = missile_scene.instantiate()
	else:
		projectile = bullet_scene.instantiate()
	projectile.position = $ProjectileSpawn.global_position
	projectile.rotation = rotation + deviation + accuracy_modifier
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
	
	# Increase difficulty after each defeat
	consecutive_defeats += 1
	difficulty_modifier = min(1.0 + (consecutive_defeats * 0.2), 2.0)
	speed = SPEED * difficulty_modifier
	reload_period = max(RELOAD_PERIOD_DEFAULT / difficulty_modifier, 0.2)
	
	# Check if AI should be permanently defeated in singleplayer mode
	if global.game_mode == 0 and consecutive_defeats >= global.ai_defeat_threshold:
		global.ai_permanently_defeated = true
		visible = false
		position = HIDING_POSITION
		# Set AI health to 0 to prevent further interactions
		global.ai_health = 0


# Enhanced AI behavior state machine
func update_ai_behavior(delta):
	state_timer += delta
	
	# Change AI state based on conditions
	if state_timer >= state_duration:
		state_timer = 0.0
		var player_distance = position.distance_to(global.p2_position)
		var health_percentage = float(global.ai_health) / MAX_HEALTH
		var player_health_percentage = float(global.p2_health) / MAX_HEALTH
		var old_state = ai_state
		
		# Choose next state based on current conditions
		if health_percentage < 0.3:
			# Low health - prioritize defense and healing items
			ai_state = AIBehaviorState.DEFENSIVE
			state_duration = randf_range(3.0, 5.0)
		elif player_distance > 250 and health_percentage > 0.5:
			# Far from player and healthy - seek powerups
			ai_state = AIBehaviorState.POWERUP_SEEKING
			state_duration = randf_range(2.0, 4.0)
		elif health_percentage > 0.7 and player_distance < 150:
			# High health and close to player - be aggressive
			ai_state = AIBehaviorState.AGGRESSIVE
			state_duration = randf_range(3.0, 6.0)
		elif player_health_percentage < 0.4 and health_percentage > 0.4:
			# Player is weak and AI is stronger - be aggressive
			ai_state = AIBehaviorState.AGGRESSIVE
			state_duration = randf_range(2.0, 4.0)
		else:
			# Default to evasive behavior
			ai_state = AIBehaviorState.EVASIVE
			state_duration = randf_range(1.5, 3.0)
		
		# Debug output (can be removed in production)
		if old_state != ai_state:
			var state_names = ["AGGRESSIVE", "DEFENSIVE", "POWERUP_SEEKING", "EVASIVE"]
			print("AI state changed from ", state_names[old_state], " to ", state_names[ai_state])


# Get target based on current AI behavior state
func get_behavior_target():
	match ai_state:
		AIBehaviorState.AGGRESSIVE:
			# Predict player movement for better targeting
			var player_velocity = global.p2_position - last_player_position
			player_velocity_prediction = global.p2_position + (player_velocity * 2.0)
			last_player_position = global.p2_position
			return player_velocity_prediction
			
		AIBehaviorState.DEFENSIVE:
			# Stay at a safe distance from player
			var direction_from_player = (position - global.p2_position).normalized()
			return global.p2_position + direction_from_player * 300
			
		AIBehaviorState.POWERUP_SEEKING:
			# Prioritize powerups more heavily
			var closest_powerup = Vector2.ZERO
			var closest_distance = INF
			
			for location in powerup_locations:
				var processed_loc = location
				if global.missile_power_hidden == true and location == missile_pwr_location:
					continue
				if global.shotgun_power_hidden == true and location == shotgun_pwr_location:
					continue
				if global.dmg_power_hidden == true and location == dmg_pwr_location:
					continue
				if global.shield_power_hidden == true and location == shield_pwr_location:
					continue
				if global.rapid_power_hidden == true and location == rapidfire_pwr_location:
					continue
				
				var distance = position.distance_to(processed_loc)
				if distance < closest_distance:
					closest_distance = distance
					closest_powerup = processed_loc
			
			return closest_powerup if closest_powerup != Vector2.ZERO else global.p2_position
			
		AIBehaviorState.EVASIVE:
			# Use evasive maneuvers
			if evasion_direction == Vector2.ZERO or randf() < 0.1:
				evasion_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			
			return global.p2_position + evasion_direction * 150
	
	return global.p2_position


# Process physics every frame, including AI movement and behaviors
func _physics_process(delta):
	# Hide AI if in game mode 1 or if permanently defeated
	if global.game_mode == 1 or global.ai_permanently_defeated:
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

	# Update AI behavior state
	update_ai_behavior(delta)
	
	# Get target based on current behavior state
	target = get_behavior_target()

	# Fallback to old powerup logic if no target found
	if target == Vector2.ZERO:
		target = global.p2_position
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

	# Calculate movement direction and speed with behavior modifications
	var direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	var distance_to_player = global_position.distance_to(global.p2_position)
	
	# Adjust speed factor based on AI state
	var base_speed_factor = clamp((distance_to_player - min_distance) / min_distance, 0, 1)
	var speed_factor = base_speed_factor
	
	match ai_state:
		AIBehaviorState.AGGRESSIVE:
			speed_factor = min(base_speed_factor * 1.3, 1.0)
		AIBehaviorState.DEFENSIVE:
			speed_factor = base_speed_factor * 0.7
		AIBehaviorState.EVASIVE:
			speed_factor = min(base_speed_factor * 1.1, 1.0)
			# Add some jittery movement for evasion
			direction += Vector2(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3))
			direction = direction.normalized()

	# Smoothly rotate towards the direction of movement
	if direction != Vector2.ZERO:
		var target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, accel * delta * 2)

	# Adjust velocity based on direction and speed
	velocity = velocity.lerp(direction * speed * speed_factor, accel * delta)

	# Enhanced shooting logic with behavior-based modifications
	if $Ray.get_collider() != null:
		if $Ray.get_collider().is_in_group("player"):
			var should_shoot = loaded
			
			# Modify shooting behavior based on AI state
			match ai_state:
				AIBehaviorState.AGGRESSIVE:
					# Always shoot when able
					should_shoot = loaded
				AIBehaviorState.DEFENSIVE:
					# Only shoot if player is close
					should_shoot = loaded and distance_to_player < 200
				AIBehaviorState.EVASIVE:
					# Shoot less frequently while evading
					should_shoot = loaded and randf() < 0.7
				AIBehaviorState.POWERUP_SEEKING:
					# Shoot if player is blocking path to powerup
					should_shoot = loaded and distance_to_player < 150
			
			if should_shoot:
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
