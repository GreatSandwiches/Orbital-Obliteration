extends Area2D

@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D
@onready var respawn_timer = $RespawnTimer

# Constants
const RESPAWN_TIME = 10

# Signals
signal ai_damageup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signal to the AI's damage boost function
	ai_damageup.connect(get_node("/root/Level/EnemyAi")._damage_up)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # No per-frame processing needed currently


# Makes the power-up disappear after being collected
func _on_damage_collect(area: Area2D) -> void:
	if area.is_in_group("player"):
		_hide_powerup()
		respawn_timer.start(RESPAWN_TIME)
		global.dmg_power_hidden = true

	if area.is_in_group("ai"):
		ai_damageup.emit()
		_hide_powerup()
		respawn_timer.start(RESPAWN_TIME)
		global.dmg_power_hidden = true


# Called when the respawn timer finishes, making the power-up reappear
func _on_respawn_timer_timeout() -> void:
	hitbox.disabled = false
	show()
	global.dmg_power_hidden = false


# Hides the power-up and disables its hitbox
func _hide_powerup() -> void:
	hitbox.set_deferred("disabled", true)
	hide()
