extends Node

# Player and game-related variables
var current_player: String = "a"  # Start with player A
@onready var board: GameBoard = $".."
@onready var place_card: PlaceCard = $PlaceCard
@onready var move_card: MoveCard = $MoveCard

# Game configuration
@export var cards_per_turn: int = 4
@export var player_b_cards_first_turn: int = 4
@export var player_a_cards_first_turn: int = 2
@export var moves_per_player: int = 6

# State tracking
var cards_played_this_turn: int = 0
var pieces_moved_this_turn: int = 0
var turn: int = 0
var selected_square: Dictionary

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return

	var mouse_position: Vector2i = get_viewport().get_mouse_position()
	var square: Dictionary = board.get_square(mouse_position)

	if event is InputEventKey:
		handle_key_input(event, square)
	elif event is InputEventMouseButton:
		handle_mouse_click(event, square)

func handle_key_input(event: InputEventKey, square: Dictionary) -> void:
	if is_number_key(event.keycode):
		handle_card_placement(event, square)
	elif event.keycode == KEY_ENTER:
		end_turn()
func handle_mouse_click(event, square):
	if event.button_index == 1:
		selected_square = square
	elif event.button_index == 2:
		if pieces_moved_this_turn >= moves_per_player:
			return
		elif move_card.move_card(selected_square, square, current_player, turn):
			pieces_moved_this_turn+=1

func is_number_key(keycode: int) -> bool:
	return keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8]

func handle_card_placement(event: InputEventKey, square: Dictionary) -> void:
	if can_play_card():
		if place_card.place_card(event, current_player, square, turn):
			cards_played_this_turn += 1

func can_play_card() -> bool:
	if turn == 0:
		if current_player == "a" and cards_played_this_turn < player_a_cards_first_turn:
			return true
		elif current_player == "b" and cards_played_this_turn < player_b_cards_first_turn:
			return true
		else:
			return false
	return cards_played_this_turn < cards_per_turn

func end_turn() -> void:
	switch_turn()
	cards_played_this_turn = 0  # Reset the card count for the next turn
	pieces_moved_this_turn = 0 # Reset the moves count for the next turn

func switch_turn() -> void:
	if current_player == "b":
		turn += 1 #The turn finish when the last player play the card
		current_player = "a"
	else:
		current_player = "b"
