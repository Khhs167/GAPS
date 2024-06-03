tool
extends Sprite

export(Array, Vector2) var tile_positions;
export var tile_level : int;

var game : Node;
var timer = -1

func set_game(game):
	self.game = game

func _ready():
	$Button.connect("pressed", self, "buy")

func _process(delta):
	for i in range(4):
		for j in range(4):
			$shape_display.map[i][j] = 0
	for p in tile_positions:
		$shape_display.map[p.y][p.x] = tile_level
	
	if(timer > -1):
		timer += delta
		rotation = Util.lerp_clamped(rotation, 0, delta * 10)
		position = Util.lerp_clamped(position, Vector2.ZERO, delta * 20)
		scale = Util.lerp_clamped(scale, Vector2.ONE, delta * 10)
	if(timer >= 2):
		print("done!")
		visible = false
		game._shop_done(self);
		timer = -1
		
	
func buy():
	$Button.visible = false
	game.upgrade_sound();
	game.shop_clear_all_but(self)
	game.camera_shake += 100
	timer = 0
	rotation = 20
	scale = Vector2.ONE * 0.1
	print("Buying tile!")
	var tile = {}
	for p in tile_positions:
		tile[p] = tile_level
	game.inventory.append(tile)
