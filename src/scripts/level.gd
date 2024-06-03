tool
extends Node2D

var colorRandom = RandomNumberGenerator.new();

var map = [
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
];



export var tile_settings : Resource;

func _process(_delta):
	update()

func _get_tile_colour(id : int) -> Color:
	
	if(id == -1):
		return tile_settings.color_completed;
	
	id -= 1
	if(len(tile_settings.colors) - 1 >= id and tile_settings.colors[id] != null):
		return tile_settings.colors[id]
	colorRandom.seed = id;
	# TODO: This causes overlap.
	return Color(colorRandom.randf(), colorRandom.randf(), colorRandom.randf())
	
func clear():
	for y in range(6):
		for x in range(20):
			map[y][x] = 0

func _draw() -> void:
	for y in range(6):
		for x in range(20):
			if(map[y][x] != 0):
				draw_texture(tile_settings.texture, tile_settings.texture.get_size() * Vector2(x, y), _get_tile_colour(map[y][x]))
			if(map[y][x] == 0 && tile_settings.show_blanks):
				draw_texture(tile_settings.texture, tile_settings.texture.get_size() * Vector2(x, y), Color.gray)
