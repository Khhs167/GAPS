extends Sprite

var game : Node;
var timer = -1
var tile;
var index = 0;

func set_game(game):
	$shape_display.map = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
	self.game = game
	index = floor(rand_range(0, len(game.inventory)));
	tile = game.inventory[index]
	print($shape_display)
	for p in tile:
		$shape_display.map[p.y][p.x] = tile[p]

func _ready():
	$Button.connect("pressed", self, "buy")

func _process(delta):	
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
	game.inventory.remove(index)
