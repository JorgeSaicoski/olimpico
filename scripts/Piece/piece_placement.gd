class_name PiecePlacement extends Node

signal piece_placed(piece: GamePiece, square: Square)

# Piece definitions for each player
var piece_definitions = {
	"a": {
		1: {"name": "Knight", "hp": 12, "attack": 3, "defense": 2, "move_cost": 1, "attack_cost": 3},
		2: {"name": "Archer", "hp": 8, "attack": 4, "defense": 1, "move_cost": 2, "attack_cost": 2},
		3: {"name": "Tank", "hp": 15, "attack": 2, "defense": 3, "move_cost": 2, "attack_cost": 4},
		4: {"name": "Assassin", "hp": 6, "attack": 5, "defense": 1, "move_cost": 1, "attack_cost": 2}
	},
	"b": {
		1: {"name": "Knight", "hp": 12, "attack": 3, "defense": 2, "move_cost": 1, "attack_cost": 3},
		2: {"name": "Archer", "hp": 8, "attack": 4, "defense": 1, "move_cost": 2, "attack_cost": 2},
		3: {"name": "Tank", "hp": 15, "attack": 2, "defense": 3, "move_cost": 2, "attack_cost": 4},
		4: {"name": "Assassin", "hp": 6, "attack": 5, "defense": 1, "move_cost": 1, "attack_cost": 2}
	}
}

var board: GameBoard
var current_turn: int = 1

func _init(game_board: GameBoard) -> void:
	board = game_board

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var piece_number = -1
		
		# Check for number keys 1-4
		match event.keycode:
			KEY_1: piece_number = 1
			KEY_2: piece_number = 2
			KEY_3: piece_number = 3
			KEY_4: piece_number = 4
		
		if piece_number != -1:
			try_place_piece(piece_number)

func try_place_piece(piece_number: int) -> void:
	var mouse_pos = board.get_local_mouse_position()
	var square = get_square_under_mouse(mouse_pos)
	
	if square and can_place_piece_at(square):
		var current_player = get_current_player()
		create_and_place_piece(piece_number, current_player, square)

func get_square_under_mouse(mouse_pos: Vector2) -> Square:
	var board_pos = Vector2i(
		floor(mouse_pos.x / board.cell_size),
		floor(mouse_pos.y / board.cell_size)
	)
	return board.get_square(board_pos)

func can_place_piece_at(square: Square) -> bool:
	if square.has_piece():
		return false
		
	var current_player = get_current_player()
	var row = square.board_position.y
	
	# Player A can only place in first two rows (0-1)
	if current_player == "a":
		return row <= 1
	
	# Player B can only place in last two rows (6-7 for 8x8 board)
	elif current_player == "b":
		return row >= board.board_size.y - 2
		
	return false

func create_and_place_piece(piece_number: int, player: String, square: Square) -> void:
	var piece_def = piece_definitions[player][piece_number]
	if not piece_def:
		return
		
	var piece_scene = preload("res://scenes/piece.tscn")
	var piece: GamePiece = piece_scene.instantiate()
	
	# Configure piece based on definition
	piece.max_hp = piece_def["hp"]
	piece.attack_power = piece_def["attack"]
	piece.defense = piece_def["defense"]
	piece.movement_cost = piece_def["move_cost"]
	piece.attack_cost = piece_def["attack_cost"]
	
	# Initialize piece
	piece.initialize(
		piece_def["name"],
		player,
		square.board_position,
		current_turn
	)
	
	# Add piece to the scene and square
	board.add_child(piece)
	square.set_piece(piece)
	
	emit_signal("piece_placed", piece, square)

func get_current_player() -> String:
	# This should be updated based on your turn management system
	# For now, let's use a simple system
	return "a" if current_turn % 2 == 1 else "b"

func set_turn(turn: int) -> void:
	current_turn = turn
