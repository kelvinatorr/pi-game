extends Node

func _ready() -> void:
	load_main_menu()

func load_main_menu() -> void:
	var main_menu = load('res://ui/MainMenu.tscn').instance()
	add_child(main_menu)
	$MainMenu/MarginContainer/HBoxContainer/MenuContainer/NewGame.connect("pressed", self, "on_new_game_pressed")
	$MainMenu/MarginContainer/HBoxContainer/MenuContainer/Exit.connect("pressed", self, "on_quit_pressed")

func on_new_game_pressed() -> void:
	$MainMenu.queue_free()
	var game_scene = load('res://main/Game.tscn').instance()
	game_scene.connect('game_over', self, 'show_game_over')
	add_child(game_scene)

func on_quit_pressed() -> void:
	get_tree().quit()

func show_game_over() -> void:
	var game_over: CanvasLayer = load('res://ui/GameOver.tscn').instance()
	add_child(game_over)
	$GameOver/MarginContainer/VBoxContainer/HBoxContainer/Retry.connect('pressed', self, 
		'on_retry_pressed')
	$GameOver/MarginContainer/VBoxContainer/HBoxContainer/MainMenu.connect('pressed', self, 
		'on_main_menu_pressed')

func on_retry_pressed() -> void:
	print('Retry')
	# TODO: Set Energy Back to Max
	# TODO: Re-enable movement
	# TODO: Remove All Items
	# TODO: Unload the Game Over Scene

func on_main_menu_pressed() -> void:
	$Game.queue_free()
	$GameOver.queue_free()
	load_main_menu()
