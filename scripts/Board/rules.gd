class_name GameRules
extends Node

# Player Setup Rules
@export var first_player: String = "a"
@export var first_turn_just_place_king: bool = true

# Card Placement Rules
@export var place_card: bool = true
@export var number_cards_first_turn: int = 4
@export var number_cards_played_per_turn: int = 1
@export var first_player_dont_play_card_turn_1: bool = true

# Movement Rules
@export var movement_power_per_turn: int = 12
@export var can_piece_move_and_attack: bool = false

# Combat Rules
@export var phase_to_attack: bool = true
@export var turns_to_see_opponent_pieces: int = 1

# Game Phase Rules
@export var first_turn_dont_change_moon: bool = true

func validate() -> bool:
	# Add any complex validation logic here
	return first_player != "" and number_cards_played_per_turn > 0
