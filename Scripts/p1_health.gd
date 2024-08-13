extends ProgressBar

@onready var global = get_node("/root/Global")
var needed_position = Vector2(0,0)

func _ready():
	pass

func _process(delta):
	self.value = global.p1_health
	needed_position = global.p1_position + Vector2(-20,20)
	position =  needed_position
