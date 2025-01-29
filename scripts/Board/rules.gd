class_name GameRules
extends Node

# Player Setup Rules
@export var first_player: String = "a"

# Placement Rules
@export var placement_rows_per_player: int = 2  # Number of rows each player gets for placement
@export var max_cards_per_player: int = 15      # Including king
@export var cards_first_turn: int = 4           # Number of cards to place in turn 2

# Movement Rules
@export var movement_power_per_turn: int = 12
@export var can_move_and_attack: bool = false

# Combat Rules
@export var turns_to_see_opponent_pieces: int = 1

# Board Reference
var board: GameBoard

# Piece Definitions
var piece_stats = {
	"King": {
		"hp": 15,
		"attack": 3,
		"defense": 2,
		"move_cost": 1,
		"attack_cost": 3
	},
	"Knight": {
		"hp": 12,
		"attack": 3,
		"defense": 2,
		"move_cost": 1,
		"attack_cost": 3
	},
	"Archer": {
		"hp": 8,
		"attack": 4,
		"defense": 1,
		"move_cost": 2,
		"attack_cost": 2
	},
	"Tank": {
		"hp": 15,
		"attack": 2,
		"defense": 3,
		"move_cost": 2,
		"attack_cost": 4
	},
	"Assassin": {
		"hp": 6,
		"attack": 5,
		"defense": 1,
		"move_cost": 1,
		"attack_cost": 2
	}
}

func _ready() -> void:
	board = get_parent() as GameBoard
	
	# Validate placement rows don't exceed board size
	if placement_rows_per_player * 2 > board.board_size.y:
		push_warning("Placement rows per player is too large for board height!")
		placement_rows_per_player = board.board_size.y / 4  # Set to 1/4 of board height

func validate() -> bool:
	return (
		first_player != "" and 
		placement_rows_per_player > 0 and
		placement_rows_per_player * 2 <= board.board_size.y
	)

func get_player_placement_rows(player: String) -> Vector2i:
	if player == "a":
		# Player A gets the first N rows
		return Vector2i(0, placement_rows_per_player - 1)
	else:
		# Player B gets the last N rows
		return Vector2i(
			board.board_size.y - placement_rows_per_player,
			board.board_size.y - 1
		)

func is_valid_placement_position(position: Vector2i, player: String) -> bool:
	# Check if position is within board bounds
	if position.x < 0 or position.x >= board.board_size.x or \
	   position.y < 0 or position.y >= board.board_size.y:
		return false
	
	var valid_rows = get_player_placement_rows(player)
	return position.y >= valid_rows.x and position.y <= valid_rows.y

func get_piece_stats(piece_name: String) -> Dictionary:
	return piece_stats.get(piece_name, {})

func is_valid_board_position(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < board.board_size.x and \
		   position.y >= 0 and position.y < board.board_size.y

func is_king_alive(player: String) -> bool:
	# This function should be implemented to check if a player's king is still alive
	# You'll need to track this in your game state
	return false
	
