tool
extends Polygon2D

export var PostBox : NodePath;

func _ready():
	print(OS.get_name())
	if OS.get_name() == "HTML5":
		get_node(PostBox).pressed = false;

func _draw():
	var backbuffer_image = get_viewport().get_texture().get_data()
	
	var texture = ImageTexture.new();
	texture.create_from_image(backbuffer_image);

	material.set_shader_param("wonk", texture)
func _process(_delta):
	update()

func _bloom_changed(value):

	var mat : ShaderMaterial = material;
	print("New B value: ", value);
	material.set_shader_param("bloom_strength", value / 10)
	material.set_shader_param("do_bloom", value > 0)


func _crt_changed(value):
	var percent = value / 10;
	print("New C value: ", value);
	material.set_shader_param("curvature", Util.lerp_clamped(Vector2(10, 10), Vector2(5, 5), percent))
	material.set_shader_param("do_curve", value > 0)


func _bloom_q_changed(value):
	print("New BQ value: ", value);
	material.set_shader_param("bloom_level", value)


func _bright_change(value):
	material.set_shader_param("brightness", value)

func _blur_changed(value):
	material.set_shader_param("wonk_strength", lerp(0, 0.9, value))


func _on_post_box_toggled(button_pressed):
	visible = button_pressed;


func _noise_changed(value):
	material.set_shader_param("noise_strength", lerp(0, 0.01, value))
