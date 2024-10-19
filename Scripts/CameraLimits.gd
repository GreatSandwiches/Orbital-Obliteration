extends Node

# Variables to store camera limits
var limit_left = 0
var limit_right = 1150
var limit_top = 0
var limit_bottom = 600


# Function to set the camera limits
func set_limits(left, right, top, bottom):
	limit_left = left
	limit_right = right
	limit_top = top
	limit_bottom = bottom
