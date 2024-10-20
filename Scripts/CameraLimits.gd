extends Node

# Constants for default camera limits
const DEFAULT_LIMIT_LEFT = 0
const DEFAULT_LIMIT_RIGHT = 1150
const DEFAULT_LIMIT_TOP = 0
const DEFAULT_LIMIT_BOTTOM = 600

# Variables to store camera limits
var limit_left = DEFAULT_LIMIT_LEFT
var limit_right = DEFAULT_LIMIT_RIGHT
var limit_top = DEFAULT_LIMIT_TOP
var limit_bottom = DEFAULT_LIMIT_BOTTOM


# Function to set the camera limits
func set_limits(left: int, right: int, top: int, bottom: int) -> void:
	limit_left = left
	limit_right = right
	limit_top = top
	limit_bottom = bottom
