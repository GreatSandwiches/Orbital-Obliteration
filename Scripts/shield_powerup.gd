extends Area2D

@onready var global = get_node("/root/Global")
@onready var hitbox = $CollisionShape2D
@onready var respawn_timer = $RespawnTimer

# Constants
const RESPAWN_TIME = 10

# Signals
signal collect1
signal collect2
signal aicollect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals to shield power-up collection functions for players and AI
	collect1.connect(get_node("/root/Level/Player1")._shield_powerup_collected)
	collect2.connect(get_node("/root/Level/Player2")._shield_powerup_collected)
	aicollect.connect(get_node("/root/Level/EnemyAi")._shield_powerup_collected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # No per-frame processing needed currently


# Handles the collection of the shield power-up by players or AI
func _collected(area: Area2D) -> void:
	if area.is_in_group("player1"):
		_emit_collect_signal(collect1)
	elif area.is_in_group("player2"):
		_emit_collect_signal(collect2)
	elif area.is_in_group("ai"):
		_emit_collect_signal(aicollect)


# Restores the power-up after the respawn timer finishes
func _duration_end() -> void:
	hitbox.disabled = false
	show()
	global.shield_power_hidden = false


# Emits the appropriate signal and hides the power-up
func _emit_collect_signal(signal_to_emit: Signal) -> void:
	signal_to_emit.emit()
	hitbox.set_deferred("disabled", true)
	hide()
	respawn_timer.start(RESPAWN_TIME)
	global.shield_power_hidden = true
