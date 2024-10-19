extends Node

# P1 Variables
var p1_score = 0
var p1_location = Vector2(0,0)
var p1_health = 100
var p1_gunheat = 0
var p1_maxgunheat = 10
var p1_coolingrate = 3
var p1_firerate = 0.3
var p1_gundamage = 1
var p1_bulletsize = 1
var p1_bulletspeed = 1
var spacemine_collision_pos_p1 = Vector2(0,0)
var p1_position = Vector2(0,0)
var p1_velocity = Vector2(0,0)
var p1_gundamagepowerup = false


# P2 Variables
var p2_score = 0
var p2_location = Vector2(0,0)
var p2_health = 100
var p2_gunheat = 0
var p2_maxgunheat = 10
var p2_coolingrate = 3
var p2_firerate = 0.3
var p2_gundamage = 1
var p2_bulletsize = 1
var p2_bulletspeed = 1
var spacemine_collision_pos_p2 = Vector2(0,0)
var p2_position = Vector2(0,0)
var p2_velocity = Vector2(0,0)
var p2_gundamagepowerup = false


#AI Variables
var ai_health = 100 # Max health for AI
var ai_position = Vector2(0,0)
var enemy_rapid = false
var enemy_shotgun = false
var enemy_damage = false


# General Variables
var asteroid1_pos = Vector2(0,0)
var wall_pos1 = Vector2(0,0)
var selected_level = "res://Scenes/level.tscn"
var level_1 = "res://Scenes/level.tscn"
var level_2 = "res://Scenes/level2.tscn"
var game_mode = 0  # 0 for singleplayer 1 for multiplayer
var paused = false
var ismainmenu = true
var volume = 1
var isaudiomenushowing = false
var ispausesettings_showing = false
var isgraphicsmenushowing = false
var ispausemenushowing = false
var shieldpowerhidden = false
var shotgunpowerhidden = false
var dmgpowerhidden = false
var rapidpowerhidden = false
var missilepowerhidden = false
var is_muted: bool = false
var fullscreen = false
var selected_resolution = 1 
var quality = 0
var settings_loaded = false

