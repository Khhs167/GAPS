extends Label

export var shake = 0;

var timer = 0;
var display_shake = 0;

var base : Vector2;

func _ready():
	base = get_rect().position


func _process(delta):
	timer += delta
	if(timer >= PI * 6):
		timer -= PI * 6
	shake = Util.lerp_clamped(shake, 0, delta * 20)
	if(shake < 0):
		shake = 0
		
	display_shake = Util.lerp_clamped(display_shake, shake, delta * 20);
		
	set_position(base + Vector2(rand_range(-0.1, 0.1) * display_shake, rand_range(-0.1, 0.1) * display_shake))
	set_rotation(rand_range(-1, 1) * shake)
