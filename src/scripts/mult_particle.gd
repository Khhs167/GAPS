extends Node2D

var life = 1;
var dir;

var v;

func _ready():
	dir = rand_range(0, 365)
	v = Vector2(sin(deg2rad(dir)), cos(deg2rad(dir)))

func _process(delta):
	life -= delta;
	if(life <= 0):
		queue_free()
	position += v * delta * 20;
	modulate.a = life;
