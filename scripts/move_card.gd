class_name MoveCard
extends Node
@onready var board: GameBoard = $"../.."

var piece: Dictionary
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func move_card(initial_square:Dictionary, to_square: Dictionary, player: String, turn:int) -> bool:
	if to_square["piece"] != null:
		return false
	piece = board.remove_piece(initial_square)
	var square_moved:Vector2i = initial_square["position"] - to_square["position"]
	var square_moved_x: int = ensure_positive(square_moved.x)
	var square_moved_y: int = ensure_positive(square_moved.y)

	if not piece.has("player"):
		return false
	elif to_square["piece"] or piece.player != player or square_moved_x>1 or square_moved_y>1 or piece["turn_placed"] == turn:
		initial_square["piece"] = piece
		return false
	elif board.add_piece(piece, to_square):
		return true
	return false
	
func ensure_positive(number: int) -> int:
	if number < 0:
		return abs(number)  # Convert to positive
	return number
