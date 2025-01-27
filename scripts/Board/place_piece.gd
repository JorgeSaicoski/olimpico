class_name PlaceCard
extends Node
@onready var board: GameBoard = $"../../.."

@export var row_allowed: int = 2  # How much row does each play have
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func place_card(event: InputEventKey, current_player: String, square: Dictionary, turn:int) -> bool:
	var piece_name: String
	# Ensure square has a valid position
	if not square.has("position"):
		return false
	var position_y = square["position"].y
	var max_row = board.board_size.y
	# Check if the piece placement is allowed for the current player
	if current_player == "a" and position_y < max_row - row_allowed:
		return false
	if current_player == "b" and position_y >= row_allowed:
		return false
	# Determine the piece name based on the input key
	match event.keycode:
		KEY_1: piece_name = "1"
		KEY_2: piece_name = "2"
		KEY_3: piece_name = "3"
		KEY_4: piece_name = "4"
		KEY_5: piece_name = "5"
		KEY_6: piece_name = "6"
		KEY_7: piece_name = "7"
		KEY_8: piece_name = "8"
	# Add the piece to the board if possible
	var piece: Dictionary = {
		"name": piece_name,
		"player": current_player,
		"turn_placed": turn
	}
	if board and board.add_piece(piece, square):
		return true
	return false
