extends Node

var MAX_TURTLE_ENERGY: int = 1000
var turtle_energy: int = MAX_TURTLE_ENERGY
var energy_per_second: int = 1
var game_over: bool = false

var FOOD: Dictionary = {
	"Shrimp": {"path": "res://items/Shrimp.tscn"},
	"Koi": {"path": "res://items/Koi.tscn"},
	"GreenPellet": {"path": "res://items/GreenPellet.tscn"},
	"JumboPellet": {"path": "res://items/JumboPellet.tscn"},
	"Poop": {"path": "res://items/Poop.tscn"},
}

signal game_over()

var poop_scene: PackedScene = preload("res://items/Poop.tscn")
var surface_scene: PackedScene = preload('res://world/TankPlatform.tscn')
var surface_player_scene: PackedScene = preload('res://player/PlayerPlatform.tscn')
var underwater_scene: PackedScene = preload('res://world/TankUnderwater.tscn')
var underwater_player_scene: PackedScene = preload('res://player/Player.tscn')

func _ready() -> void:
	$EnergyTimer.start()

func _on_EnergyTimer_timeout() -> void:
	reduce_energy(energy_per_second)

func increase_energy(val: int) -> void:
	if turtle_energy >= MAX_TURTLE_ENERGY:
		return
	turtle_energy += val
	$UI.update_energy(turtle_energy)

func reduce_energy(val: int) -> void:
	if game_over:
		return
	turtle_energy -= val
	if turtle_energy < 0:
		game_over()
	else:
		$UI.update_energy(turtle_energy)

func game_over() -> void:
	print('Game Over')
	if self.has_node("Player"):
		$Player.game_over_sequence()
	elif self.has_node("PlayerPlatform"):
		$PlayerPlatform.game_over_sequence()
	emit_signal("game_over")
	$EnergyTimer.stop()
	game_over = true

func _physics_process(delta):
	# get food button pressed
	if Input.is_action_just_pressed("feed_shrimp"):
		generate_food(FOOD["Shrimp"], null)
	elif Input.is_action_just_pressed("feed_green_pellet"):
		generate_food(FOOD["GreenPellet"], null)
	elif Input.is_action_just_pressed("feed_koi"):
		generate_food(FOOD["Koi"], null)
	elif Input.is_action_just_pressed("feed_jumbo_pellet"):
		generate_food(FOOD["JumboPellet"], null)

func generate_food(food_data: Dictionary, position) -> void:
	# Check that TankUnderwater Level is loaded
	var level: Node2D = get_node_or_null("TankUnderwater")
	if not level:
		return

	if position == null:
		# Generate a random vector for the food to spawn into
		position = Vector2(float(randi() % int(level.Food_Spawn_Vector.x) + 2), 
			float(randi() % int(level.Food_Spawn_Vector.y) + 2))

	var food: Node2D = load(food_data.path).instance()
	food.position = position
	add_child_below_node($Player, food, true)
	food.connect("chomped", self, "_on_food_chomped")

func _on_Player_pooping(butt_global_pos):
	var poop: RigidBody2D = poop_scene.instance()
	add_child(poop)
	poop.global_position = butt_global_pos
	poop.connect("chomped", self, "_on_food_chomped")

func _on_food_chomped(energy_value: int, show_heart: bool):
	increase_energy(energy_value)
	if show_heart:
		$Player.show_heart()

func _on_Player_movement(energy_consumption) -> void:
	reduce_energy(energy_consumption)

func _on_Player_sleeping() -> void:
	$EnergyTimer.wait_time = 10

func _on_Player_woke_up() -> void:
	if $EnergyTimer.wait_time != 1:
		$EnergyTimer.wait_time = 1

var items_underwater: Array = []

func _on_Player_surfaced() -> void:
	# Change level to surface scene
	# Remove underwater scene
	$TankUnderwater.queue_free()
	# Remove player
	$Player.queue_free()
	items_underwater = []
	# queue free all food and poops too
	for i in get_tree().get_nodes_in_group("item"):
		var save_item: Array = [get_node_name(i), i.position]
		items_underwater.append(save_item)
		i.queue_free()
	# Load surface scene
	add_child(surface_scene.instance())
	# Add player platform
	var surface_player: KinematicBody2D = surface_player_scene.instance()
	surface_player.connect('slid_down_ramp', self, '_on_Player_slid_ramp')
	add_child(surface_player)

func _on_Player_slid_ramp() -> void:
	# Change level to underwater scene
	# Remove platform scene
	$TankPlatform.queue_free()
	# Remove player platform
	$PlayerPlatform.queue_free()
	# Load underwater scene
	add_child(underwater_scene.instance())
	# Add player
	var underwater_player: KinematicBody2D = underwater_player_scene.instance()
	underwater_player.connect('pooping', self, '_on_Player_pooping')
	underwater_player.connect('movement', self, '_on_Player_movement')
	underwater_player.connect('sleeping', self, '_on_Player_sleeping')
	underwater_player.connect('woke_up', self, '_on_Player_woke_up')
	underwater_player.connect('surfaced', self, '_on_Player_surfaced')
	underwater_player.position = Vector2(10, 10)
	add_child(underwater_player)
	# add items previously underwater
	for i in items_underwater:
		generate_food(FOOD[i[0]], i[1])


func get_node_name(node: Node) -> String:
	var regex = RegEx.new()
	regex.compile("([a-zA-Z]+)")
	var result: RegExMatch = regex.search(node.get_name())
	if result:
		return result.get_string()
	return ""
