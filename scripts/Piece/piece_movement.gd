class_name PieceMovement extends Node

signal movement_completed(piece: GamePiece, new_position: Vector2i)
signal movement_failed(piece: GamePiece, reason: String)

var board: GameBoard

func _init(game_board: GameBoard) -> void:
	board = game_board

# Calculate the power cost for a move
func calculate_move_cost(piece: GamePiece, target_pos: Vector2i) -> int:
	var distance = get_manhattan_distance(piece.current_position, target_pos)
	return distance * piece.movement_cost

# Validates if a move is legal (ignoring power constraints)
func is_valid_move(piece: GamePiece, target_pos: Vector2i) -> Dictionary:
	# Check if target position is on board
	if not board.is_valid_position(target_pos):
		return {"valid": false, "reason": "Invalid board position"}
		
	# Check if target square is occupied
	var target_square = board.get_square(target_pos)
	if target_square.has_piece():
		return {"valid": false, "reason": "Square is occupied"}
		
	# Check if piece has already moved this turn
	if piece.moves_this_turn.size() > 0 and not board.rules_manager.can_move_and_attack:
		return {"valid": false, "reason": "Piece has already moved this turn"}
		
	return {"valid": true, "reason": ""}

# Execute the movement (assumes validation is already done)
func execute_move(piece: GamePiece, target_pos: Vector2i) -> bool:
	var old_square = board.get_square(piece.current_position)
	var new_square = board.get_square(target_pos)
	
	# Remove piece from old square
	old_square.remove_piece()
	
	# Update piece position and place in new square
	piece.move_to(target_pos, board.rules_manager.current_turn)
	new_square.set_piece(piece)
	
	movement_completed.emit(piece, target_pos)
	return true

# Get all possible moves without considering power constraints
func get_possible_moves(piece: GamePiece) -> Array[Vector2i]:
	var possible_moves: Array[Vector2i] = []
	var current_pos = piece.current_position
	
	# Check a reasonable range around the piece
	# This could be configured based on board size or piece type
	var range = 8  # Can be adjusted based on game rules
	
	for x in range(-range, range + 1):
		for y in range(-range, range + 1):
			var target_pos = Vector2i(
				current_pos.x + x,
				current_pos.y + y
			)
			
			if is_valid_move(piece, target_pos).valid:
				possible_moves.append(target_pos)
	
	return possible_moves

# Helper function to calculate Manhattan distance
func get_manhattan_distance(from: Vector2i, to: Vector2i) -> int:
	return abs(to.x - from.x) + abs(to.y - from.y)
