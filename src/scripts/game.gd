extends Node2D

var inventory = []
var inventory_used = []
var round_score = 0
var round_score_limit = 200
var reshuffles_base = 5
var reshuffles = reshuffles_base

var buys_left = 0

var skip_incentive = null

const INCENTIVES = [
	"SCORE_HALF",
	"TRIPLE_MULT_RC",
	"EXTRA_BUY",
	"LEVEL_DOWN",
	"NONE",
	"NONE",
	"NONE",
	"NONE",
	"NONE",
	"NONE",
	"NONE",
	"NONE",
	"NONE",
	"NONE",
]

const INCENTIVES_LOC = {
	"SCORE_HALF": "Half Target Score (%rf > %rt)",
	"TRIPLE_MULT_RC": "3x Row Clear Score",
	"EXTRA_BUY": "+1 Buy Next Round",
	"LEVEL_DOWN": "Decreave Level By 1",
	"NONE": "Nothin'"
}


export var shop_pool : Resource;
export var mult_particle : PackedScene;

var level = 0

var game_state = "main_menu"

var camera_shake = 0

var row_mults_base = [
	1,
	2,
	3,
	3,
	2,
	1
]

var row_mults = [
	1,
	2,
	3,
	3,
	2,
	1
]

const level_scores = [
	200,
	300,
	400,
	500,
	600,
	700,
	800,
	1000,
	1200,
	1300,
	1500,
	1700,
	1900,
	2200,
	2500,
	2800,
	3200,
	3600,
	4000,
	4500,
	5000,
	5500,
	6500,
	7500,
	8500,
	10000,
	11500,
	13000
	# we give up.
]

const shape_l_0 = {
	Vector2(0, 0): 1,
	Vector2(1, 0): 1,
	Vector2(2, 0): 1,
	Vector2(2, 1): 1
}

const shape_l_1 = {
	Vector2(0, 0): 1,
	Vector2(1, 0): 1,
	Vector2(2, 0): 1,
	Vector2(0, 1): 1
}

const shape_l_2 = {
	Vector2(0, 1): 1,
	Vector2(1, 1): 1,
	Vector2(2, 1): 1,
	Vector2(2, 0): 1
}

const shape_l_3 = {
	Vector2(0, 0): 1,
	Vector2(0, 1): 1,
	Vector2(1, 1): 1,
	Vector2(2, 1): 1
}

const shape_l_4 = {
	Vector2(0, 0): 1,
	Vector2(1, 0): 1,
	Vector2(1, 1): 1,
	Vector2(1, 2): 1
}

const shape_l_5 = {
	Vector2(1, 0): 1,
	Vector2(0, 0): 1,
	Vector2(0, 1): 1,
	Vector2(0, 2): 1
}


const shape_single = {
	Vector2(0, 0): 1,
}

const shape_stick = {
	Vector2(0, 0): 1,
	Vector2(1, 0): 1,
	Vector2(2, 0): 1,
	Vector2(3, 0): 1,
	
}

const shape_stick_short = {
	Vector2(0, 0): 1,
	Vector2(1, 0): 1,
	Vector2(2, 0): 1,
}

const shape_stick_short_upright = {
	Vector2(0, 0): 1,
	Vector2(0, 1): 1,
	Vector2(0, 2): 1,
}

const shape_stick_2 = {
	Vector2(0, 0): 1,
	Vector2(0, 1): 1,
}

const shape_stick_2_upright = {
	Vector2(0, 0): 1,
	Vector2(0, 1): 1,
}

const shape_quad= {
	Vector2(0, 0): 1,
	Vector2(0, 1): 1,
	Vector2(1, 0): 1,
	Vector2(1, 1): 1
}
	

func _shape_upgrade(shape : Dictionary, amount = 1):
	shape = shape.duplicate()
	for p in shape:
		shape[p] += amount
	return shape

func _shape_level(shape : Dictionary, level):
	shape = shape.duplicate()
	for p in shape:
		shape[p] = level
	return shape

func _update_shape_displays():
	
	for i in range(4):
		for j in range(4):
			$state_main/current_shape.map[i][j] = 0
			$state_main/next_shape.map[i][j] = 0
	
	for p in inventory[0]:
		$state_main/current_shape.map[p.y][p.x] = inventory[0][p]
	
	if(len(inventory) >= 2):
		for p in inventory[1]:
			$state_main/next_shape.map[p.y][p.x] = inventory[1][p]

func _drop_tile(logical_x : int, drop_y : int):
	$audio/tile_drop.play()
	inventory_used.append(inventory[0])
	for p in inventory[0]:
		var y = p.y + drop_y - 1;
		var x = p.x + logical_x
		$state_main/level.map[y][x] = inventory[0][p]
		# First drop gives a 20% bonus
		var s = floor(inventory[0][p] * row_mults[p.y + drop_y - 1] * 1.2);
		round_score += s
		$state_main/score_current.shake += inventory[0][p] * row_mults[p.y + drop_y - 1]
		camera_shake += s
		
		var particle = mult_particle.instance()
		particle.get_node("Label").text = str(s);
		particle.position.x = x * 16 + ($state_main/level.position.x);
		particle.position.y = y * 16 + ($state_main/level.position.y);
		add_child(particle)
		
		
	inventory.remove(0)
	print(round_score)
	
	
	# Then we rescore any row if it's full and mark it as "scored"
	for y in range(6):
		
		if $state_main/level.map[y][0] == -1: # Row has been scored!
			continue
		
		var had_space = false
		for x in range(20):
			if $state_main/level.map[y][x] == 0:
				had_space = true
				break
		if had_space:
			continue
		$audio/line_clear.play()
		for x in range(20):
			var score = $state_main/level.map[y][x] * row_mults[y];
			if(skip_incentive == "TRIPLE_MULT_RC"):
				score *= 3
			round_score +=  score# Re-run all scores
			$state_main/score_current.shake += score
			camera_shake += $state_main/level.map[y][x] * row_mults[y]
			$state_main/level.map[y][x] = -1
			
			var particle = mult_particle.instance()
			particle.get_node("Label").text = str(score);
			particle.modulate = Color(1, 0, 0, 1)
			particle.position.x = x * 16 + ($state_main/level.position.x);
			particle.position.y = y * 16 + ($state_main/level.position.y);
			add_child(particle)
		
	
	
func _move_shape_down(x : int) -> int:
	var game_map = $state_main/level.map
	var shape = inventory[0]
	
	var highest_valid_y = 0
	
	# We see how far down we can go
	var current_y = -1
	while true:
		var found = false
		for t in shape:
			if(t.y + current_y > 5):
				found = true
				break
			if(t.y + current_y < 0):
				continue
			if(game_map[t.y + current_y][t.x + x] != 0):
				found = true
				break
		
		# If "found" is set, we're intersecting.
		# If "found" isn't set, we're not intersecting.
		
			
		current_y += 1;
		
		if(!found):
			highest_valid_y = current_y
		
		if(current_y >= 6):
			break
		
	return highest_valid_y;
	
func _current_shape_size():
	var high = -INF;
	var low = INF;
	for p in inventory[0]:
		if(high < p.x + 1):
			high = p.x + 1
		if(low > p.x):
			low = p.x
	return high - low;

var fade_timer = 0.0;

func _process_main_fadein(delta):
	camera_shake += 1000 * delta
	fade_timer += delta
	if(fade_timer <= 0.1):
		$fade_white.modulate.a = fade_timer / 0.1
	else:
		game_state = "main"

func _process_main(delta):
	

	
	if(fade_timer >= 0):
		fade_timer -= delta
	else:
		$fade_white.visible = false
	$fade_white.modulate.a = fade_timer / 0.1
	
	var mouse_tile = floor(get_global_mouse_position().x / 16);
	
	var max_width = 10 - _current_shape_size();
	
	mouse_tile = clamp(mouse_tile, -10, max_width);
	
	$state_main/current_shape.position.x = Util.lerp_clamped($state_main/current_shape.position.x, mouse_tile * 16, delta * 20)
	
	var logical_mouse_tile = mouse_tile + 10
	
	var drop_length = _move_shape_down(logical_mouse_tile)
	
	if(drop_length == 0):
		$state_main/level_display.visible = false
	else:
		$state_main/level_display.visible = true
	
	for y in range(6):
		for x in range(20):
			$state_main/level_display.map[y][x] = 0
	
	# We push tiles into the display
	for t in inventory[0]:
		if(t.y + drop_length - 1 < 0):
			continue
		$state_main/level_display.map[t.y + drop_length - 1][t.x + logical_mouse_tile] = inventory[0][t]
		
	# Time to place the tiles
	if Input.is_action_just_pressed("tile_drop") and drop_length != 0:
		# We drop down the tile and update
		_drop_tile(logical_mouse_tile, drop_length);
		_update_shape_displays();
	 
	$state_main/score_current.text = str(round_score) + "/" + str(round_score_limit)
	$state_main/shuffles_left.text = "SHUFF: " + str(reshuffles)
	$state_main/level_current.text = "LEVEL: " + str(level)
	$state_main/tile_counter.text = "TILES: " + str(len(inventory)) + "/" + str(len(inventory) + len(inventory_used))
			

	if(Input.is_action_just_pressed("inventory_shuffle") && reshuffles > 0):
		reshuffles -= 1
		inventory.shuffle()
		camera_shake += 1000
		$audio/shuffle.play()
		$audio/tile_drop.play()
		_update_shape_displays()
	
	if(reshuffles <= 0):
		var found_drop = false
		for p in range(max_width):
			var drop_test = _move_shape_down(p)
			if(drop_test != 0):
				found_drop = true
		if(!found_drop):
			print("Died at " + str(max_width))
			game_state = "game_over_entry"
			
	
	if(round_score >= round_score_limit):
		$audio/level_clear.play()
		$state_main/score_current.text = "LEVEL CLEAR"
		$state_main/score_current.display_shake = 2000;
		game_state = "level_next_in"
	



var fade_prog = 0

func _process_level_switch_in(delta):
	camera_shake += 1000 * delta
	$state_main/score_current.display_shake += 2000 * delta;
	fade_prog += delta
	if(skip_incentive == "TRIPLE_MULT_RC"):
		skip_incentive = null
	$fade_white.visible = true
	if(fade_prog <= 1.830):
		$fade_white.modulate.a = fade_prog / 1.830
	else:
		fade_prog = 0
		game_state = "level_next"

		
func _process_level_switch(delta):
	$state_main/level.clear();
	camera_shake += 1000
	game_state = "level_next_out"
	buys_left = 2
	if(skip_incentive == "EXTRA_BUY"):
		buys_left = 3
		skip_incentive = null
	
	# TODO: We should have a shop before entering the next level!
		
	$state_main.visible = false
	$state_shop.visible = true
	$state_shop/button_next.visible = true
	
	inventory.append_array(inventory_used)
	inventory_used.clear()
	
	# Set up shop
	# 3 items are available
	for c in $state_shop.get_children():
		if(c.name != "button_next"):
			$state_shop.remove_child(c)
	
	var ITEMS = 5;
	get_incentive = true;
	INCENTIVES.shuffle()
	possible_incentive = INCENTIVES[0];
	$state_shop/button_next/incentive.text = INCENTIVES_LOC[possible_incentive] \
	.replace("%rf", level_scores[level + 1]) \
	.replace("%rt", floor(level_scores[level + 1] / 2))
	$state_shop/button_next/incentive.modulate.a = 1;
	
	for i in range(ITEMS):
		
		var pool_score = rand_range(0, 100);
		var pool;
		for p in shop_pool.items:
			if(pool_score > p.limit):
				break
			pool = p;
		
		var idx = floor(rand_range(0, len(pool.items)))
	
		var item = pool.items[idx].instance();
		print("Processing " + str(item))
		item.position.x = [-140, -70, 0, 70, 140][i];
		item.set_game(self);
		$state_shop.add_child(item)

func shop_clear_all_but(node):
	for c in $state_shop.get_children():
		c.visible = c == node
	$state_shop/button_next.visible = false
	
func shop_s_all_but(node):
	for c in $state_shop.get_children():
		c.visible = c != node
	$state_shop.remove_child(node)
	$state_shop/button_next.visible = true
	
var shop_timer = 0

func upgrade_sound():
	$audio/upgrade.play()
	
func shake_generic():
	$audio/shake_generic.play()

var get_incentive = false
var possible_incentive;

func _shop_skip():
	if(get_incentive):
		skip_incentive = possible_incentive
		if(skip_incentive == "NONE"):
			skip_incentive = null
	buys_left = 1
	_shop_done(null)

func _shop_done(item):
	
	get_incentive = false;
	$state_shop/button_next/incentive.modulate.a = 0.2;
	
	camera_shake += 1000
	shake_generic()
	buys_left -= 1
	if(buys_left > 0):
		shop_s_all_but(item);
		shop_s_all_but(item);
		return
	
	camera_shake += 1000
	inventory.shuffle()
	_update_shape_displays()
	$state_main.visible = true
	$state_shop.visible = false
	shop_timer = 0.1
	game_state = "shop_timeout"
	reshuffles = reshuffles_base
		
	if(skip_incentive == "LEVEL_DOWN"):
		level -= 2
		if(level < -1):
			level = -1
		skip_incentive = null
	level += 1
	round_score = 0
	round_score_limit = level_scores[level]
	
	if(skip_incentive == "SCORE_HALF"):
		round_score_limit = floor(round_score_limit / 2)
		skip_incentive = null


func _shop_timeout(delta):
	shop_timer -= delta
	if(shop_timer <= 0):
		game_state = "main"

	
func _process_level_switch_out(delta):
	camera_shake += 100 * delta
	fade_prog += delta
	if(fade_prog <= 1):
		$fade_white.modulate.a = 1 - (fade_prog / 0.499)
	else:
		game_state = "in_shop"
		fade_prog = 0

func check_pause():
	if(Input.is_action_just_pressed("pause")):
			pause();
			
func check_unpause():
	if(Input.is_action_just_pressed("pause")):
			unpause();

func _process(delta):
	
	if(game_state == "main"):
		_process_main(delta)
		check_pause();
	elif(game_state == "main_fadein"):
		_process_main_fadein(delta)
	elif(game_state == "level_next_in"):
		_process_level_switch_in(delta)
	elif(game_state == "level_next"):
		_process_level_switch(delta)
	elif(game_state == "level_next_out"):
		_process_level_switch_out(delta)
	elif(game_state == "shop_timeout"):
		_shop_timeout(delta)
	elif(game_state == "game_over_entry"):
		_game_over_entry(delta)
	elif(game_state == "game_over_display_start"):
		_game_over_display_start(delta)
	elif(game_state == "in_shop"):
		$state_shop/button_next/Label.text = "Choose an upgrade (" + str(buys_left) + "/2)"
		check_pause();
	elif(game_state == "paused"):
		check_unpause();

	$Camera2D.offset = Vector2(rand_range(-1, 1) * camera_shake * 0.1, rand_range(-1, 1) * camera_shake * 0.1)
	camera_shake = Util.lerp_clamped(camera_shake, 0, delta * 10)

func update_row(id):
	get_node("state_main/level/row" + str(id)).text = "x" + str(row_mults[id])

func _game_over_display_start(delta):
	$screen_lose.visible = true
	camera_shake = 1000
	game_state = "game_over"
	$screen_lose/level_display.text = "LEVEL " + str(level)
	$audio/shake_generic.play()

var go_timer = 0;

func setup_game():
	inventory.clear()
	inventory_used.clear()
	for i in range(3):
		inventory.append(shape_stick)
		inventory.append(shape_single)
		inventory.append(_shape_level(shape_l_0, 3))
		inventory.append(_shape_level(shape_l_1, 3))
		inventory.append(_shape_level(shape_l_2, 3))
		inventory.append(_shape_level(shape_l_3, 3))
		inventory.append(_shape_level(shape_l_4, 3))
		inventory.append(_shape_level(shape_l_5, 3))
		inventory.append(shape_quad)
		inventory.append(_shape_level(shape_stick_short, 1))
		inventory.append(_shape_level(shape_stick_short_upright, 1))
		inventory.append(_shape_level(shape_stick_2, 1))
		inventory.append(_shape_level(shape_stick_2_upright, 1))
	inventory.shuffle()
	
	for i in range(20):
		var rand = floor(rand_range(0, len(inventory)))
		inventory[rand] = _shape_upgrade(inventory[rand])
	
	_update_shape_displays()
	
	level = 0
	$state_main/level.clear()
	round_score = 0
	round_score_limit = level_scores[level]
	skip_incentive = null
	
	reshuffles_base = 5
	reshuffles = reshuffles_base
	
	game_state = "main_fadein"
	
	$audio/shake_generic.play()
	$state_main.visible = true
	$screen_lose.visible = false;
	$screen_main_menu.visible = false;
	
	$audio/music.pitch_scale = 0.7
	
	for i in range(len(row_mults)):
		row_mults[i] = row_mults_base[i]
		update_row(i)

func _game_over_entry(delta):
	go_timer += delta
	camera_shake += 1000 * delta
	if(go_timer >= 2):
		go_timer = 0
		game_state = "game_over_display_start"

var state_pre_pause = "";

func unpause():
	print("Unpausing!")
	game_state = state_pre_pause
	$pause.visible = false;


func pause():
	print("Pausing!")
	state_pre_pause = game_state;
	game_state = "paused"
	$pause.visible = true;


func enter_main_menu():
	game_state = "main_menu"
	$state_main.visible = false
	$screen_lose.visible = false;
	$screen_main_menu.visible = true;
	$pause.visible = false;
	$settings.visible = false;


func quit():
	get_tree().quit(0)
