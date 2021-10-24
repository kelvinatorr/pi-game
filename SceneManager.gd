extends Node

func _ready() -> void:
	load_main_menu()

func load_main_menu() -> void:
	$MainMenu/MarginContainer/HBoxContainer/MenuContainer/NewGame.connect("pressed", self, "on_new_game_pressed")
	$MainMenu/MarginContainer/HBoxContainer/MenuContainer/Exit.connect("pressed", self, "on_quit_pressed")

func on_new_game_pressed() -> void:
	$MainMenu.queue_free()
	var game_scene = load("res://main/Game.tscn").instance()
	add_child(game_scene)

func on_quit_pressed() -> void:
	get_tree().quit()
