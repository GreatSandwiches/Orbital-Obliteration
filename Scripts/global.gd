extends Node

# Constants
const DEFAULT_HEALTH = 100
const DEFAULT_GUN_HEAT = 0
const DEFAULT_MAX_GUN_HEAT = 10
const DEFAULT_COOLING_RATE = 3
const DEFAULT_FIRE_RATE = 0.3
const DEFAULT_GUN_DAMAGE = 1
const DEFAULT_BULLET_SIZE = 1
const DEFAULT_BULLET_SPEED = 1
const DEFAULT_POSITION = Vector2(0, 0)

# P1 Variables
var p1_score = 0
var p1_location = DEFAULT_POSITION
var p1_health = DEFAULT_HEALTH
var p1_gun_heat = DEFAULT_GUN_HEAT
var p1_max_gun_heat = DEFAULT_MAX_GUN_HEAT
var p1_cooling_rate = DEFAULT_COOLING_RATE
var p1_fire_rate = DEFAULT_FIRE_RATE
var p1_gun_damage = DEFAULT_GUN_DAMAGE
var p1_bullet_size = DEFAULT_BULLET_SIZE
var p1_bullet_speed = DEFAULT_BULLET_SPEED
var space_mine_collision_pos_p1 = DEFAULT_POSITION
var p1_position = DEFAULT_POSITION
var p1_velocity = DEFAULT_POSITION
var p1_gun_damage_power_up = false

# P2 Variables
var p2_score = 0
var p2_location = DEFAULT_POSITION
var p2_health = DEFAULT_HEALTH
var p2_gun_heat = DEFAULT_GUN_HEAT
var p2_max_gun_heat = DEFAULT_MAX_GUN_HEAT
var p2_cooling_rate = DEFAULT_COOLING_RATE
var p2_fire_rate = DEFAULT_FIRE_RATE
var p2_gun_damage = DEFAULT_GUN_DAMAGE
var p2_bullet_size = DEFAULT_BULLET_SIZE
var p2_bullet_speed = DEFAULT_BULLET_SPEED
var space_mine_collision_pos_p2 = DEFAULT_POSITION
var p2_position = DEFAULT_POSITION
var p2_velocity = DEFAULT_POSITION
var p2_gun_damage_power_up = false

# AI Variables
var ai_health = DEFAULT_HEALTH
var ai_position = DEFAULT_POSITION
var enemy_rapid = false
var enemy_shotgun = false
var enemy_damage = false

# General Variables
var asteroid_1_pos = DEFAULT_POSITION
var wall_pos_1 = DEFAULT_POSITION
var selected_level = "res://Scenes/level.tscn"
var level_1 = "res://Scenes/level.tscn"
var level_2 = "res://Scenes/level2.tscn"
var game_mode = 0  # 0 for singleplayer, 1 for multiplayer
var paused = false
var is_main_menu = true
var volume = 1
var is_audio_menu_showing = false
var is_pause_settings_showing = false
var is_graphics_menu_showing = false
var is_pause_menu_showing = false
var shield_power_hidden = false
var shotgun_power_hidden = false
var dmg_power_hidden = false
var rapid_power_hidden = false
var missile_power_hidden = false
var is_muted: bool = false
var fullscreen = false
var selected_resolution = 1 
var quality = 0
var settings_loaded = false
