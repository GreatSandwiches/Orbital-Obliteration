extends Area2D

@onready var global = get_node("/root/Global")

# Signal to emit when a collision occurs
signal hit1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Initialization can be added here if needed.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # No specific per-frame processing required.


# Function to handle collisions with specific areas
func _collision(area) -> void:
	# Check if the collided area is part of the "ast1" group
	if area.is_in_group("ast1"):
		# Update the global wall position and emit the hit signal
		global.wall_pos1 = position
		hit1.emit(self)
