extends TextureRect

export var tile_settings : Resource;

var colorRandom = RandomNumberGenerator.new();

func _get_tile_colour(id : int) -> Color:
	id -= 1
	if(len(tile_settings.colors) - 1 >= id and tile_settings.colors[id] != null):
		return tile_settings.colors[id]
	colorRandom.seed = id;
	# TODO: This causes overlap.
	return Color(colorRandom.randf(), colorRandom.randf(), colorRandom.randf())

func _ready():
	modulate = _get_tile_colour(get_parent().get_node("HBoxContainer/SpinBox").value)

func _on_SpinBox_value_changed(value):
	modulate = _get_tile_colour(value)
