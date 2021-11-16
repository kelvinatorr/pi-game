extends Node

var MAX_TURTLE_ENERGY: int = 1000
var turtle_energy: int = MAX_TURTLE_ENERGY
var energy_per_second: int = 1
var game_over: bool = false

var FOOD: Dictionary = {
	"Shrimp": {"path": "res://items/Shrimp.tscn"},
	"Koi": {"path": "res://items/Koi.tscn"},
	"Green_Pellet": {"path": "res://items/GreenPellet.tscn"},
	"Jumbo_Pellet": {"path": "res://items/JumboPellet.tscn"},
}

signal game_over()

var poop_scene: PackedScene = preload("res://items/Poop.tscn")

func _ready() -> void:
	$EnergyTimer.start()

func _on_EnergyTimer_timeout() -> void:
	reduce_energy(energy_per_second)

func _on_Player_movement(energy_consumption) -> void:
	reduce_energy(energy_consumption)

func _on_Player_chomp_success(energy_value: int):
	increase_energy(energy_value)

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
	$Player.game_over_sequence()
	emit_signal("game_over")
	$EnergyTimer.stop()
	game_over = true

func _physics_process(delta):
	# get food button pressed
	if Input.is_action_just_pressed("feed_shrimp"):
		generate_food(FOOD["Shrimp"])
	elif Input.is_action_just_pressed("feed_green_pellet"):
		generate_food(FOOD["Green_Pellet"])
	elif Input.is_action_just_pressed("feed_koi"):
		generate_food(FOOD["Koi"])
	elif Input.is_action_just_pressed("feed_jumbo_pellet"):
		generate_food(FOOD["Jumbo_Pellet"])

func generate_food(food_data: Dictionary) -> void:
	# Check that TankUnderwater Level is loaded
	var level: Node2D = get_node_or_null("TankUnderwater")
	if not level:
		return
	# Generate a random vector for the food to spawn into
	var spawn_point: Vector2 = Vector2(float(randi() % int(level.Food_Spawn_Vector.x) + 2), 
		float(randi() % int(level.Food_Spawn_Vector.y) + 2))

	var food: Node2D = load(food_data.path).instance()
	food.position = spawn_point
	add_child_below_node($Player, food)
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


func _on_Player_sleeping() -> void:
	$EnergyTimer.wait_time = 10


func _on_Player_woke_up() -> void:
	if $EnergyTimer.wait_time != 1:
		$EnergyTimer.wait_time = 1
