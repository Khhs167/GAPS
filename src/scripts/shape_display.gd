tool
extends Node2D

var colorRandom = RandomNumberGenerator.new();

export(Array, Array, int) var map = [[]];


export var tile_settings : Resource;
export var center_tiles : bool = false


func _process(delta):
	update()

func _get_tile_colour(id : int) -> Color:
	id -= 1
	if(len(tile_settings.colors) - 1 >= id and tile_settings.colors[id] != null):
		return tile_settings.colors[id]
	colorRandom.seed = id;
	# TODO: This causes overlap.
	return Color(colorRandom.randf(), colorRandom.randf(), colorRandom.randf())

func _calculate_aabb() -> Array:
	# 0 - Min, 1 - Max
	var data = [Vector2.INF, -Vector2.INF]
	for y in range(len(map)):
		for x in range(len(map[y])):
			if((map[y][x] != 0) || (map[y][x] == 0 && tile_settings.show_blanks)):
				var start = tile_settings.texture.get_size() * Vector2(x, y);
				var end = start + tile_settings.texture.get_size();
				if(start.x < data[0].x):
					data[0].x = start.x;
				if(start.y < data[0].y):
					data[0].y = start.y;
				if(end.x > data[1].x):
					data[1].x = end.x;
				if(end.y > data[1].y):
					data[1].y = end.y;
	return data;

func _draw() -> void:
	
	if(center_tiles):
		var aabb = _calculate_aabb();
		var size = aabb[1] - aabb[0];
		draw_set_transform(-size / 2, 0, Vector2.ONE);
	
	for y in range(len(map)):
		for x in range(len(map[y])):
			if(map[y][x] != 0):
				draw_texture(tile_settings.texture, tile_settings.texture.get_size() * Vector2(x, y), _get_tile_colour(map[y][x]))
			if(map[y][x] == 0 && tile_settings.show_blanks):
				draw_texture(tile_settings.texture, tile_settings.texture.get_size() * Vector2(x, y), Color.gray)
