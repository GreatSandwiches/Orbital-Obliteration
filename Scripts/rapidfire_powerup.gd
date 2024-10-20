extends Area2D

@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D
@onready var respawn_timer = $RespawnTimer

# Constants
const RESPAWN_TIME = 10

# Signals
signal ai_rapid


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the AI rapid fire signal to the corresponding function
	ai_rapid.connect(get_node("/root/Level/EnemyAi")._rapid_fire)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # No per-frame processing needed currently


# Handles the collection of the rapid fire power-up by players or AI
func _rapidfire_collect(area: Area2D) -> void:
	if area.is_in_group("player"):
		_hide_powerup()
		respawn_timer.start(RESPAWN_TIME)
		global.rapid_power_hidden = true
		
	elif area.is_in_group("ai"):
		ai_rapid.emit()
		_hide_powerup()
		respawn_timer.start(RESPAWN_TIME)
		global.rapid_power_hidden = true


# Restores the power-up after the respawn timer finishes
func _on_respawn_timer_timeout() -> void:
	hitbox.disabled = false
	show()
	global.rapid_power_hidden = false


# Hides the power-up and disables its hitbox
func _hide_powerup() -> void:
	hitbox.set_deferred("disabled", true)
	hide()
