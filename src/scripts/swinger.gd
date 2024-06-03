extends Label

var base : Vector2;
var timer = 0;

func _ready():
	base = get_rect().position

func _process(delta):
	timer += delta
	set_rotation(sin(timer * 2) * 0.1)
	set_position(base + (Vector2.UP * cos(timer * 2) * 5))
