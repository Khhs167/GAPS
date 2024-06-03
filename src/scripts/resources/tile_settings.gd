extends Resource

export var texture : Texture;
export(Array, Color) var colors : Array = [
	Color.red,
	Color.blue,
	Color.yellow
];
export var color_completed : Color;

export var show_blanks = true
