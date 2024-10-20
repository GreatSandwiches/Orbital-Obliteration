extends Node2D

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Hide the AI if the game mode is set to 1.
	if global.game_mode == 1:
		visible = false

	# Update AI health bar and position.
	$AI_Healthbar.value = global.ai_health
	position = global.ai_position
