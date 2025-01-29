class_name GameBoard extends Node2D

signal piece_placed(piece: GamePiece, square: Square)
signal piece_moved(piece: GamePiece, from_pos: Vector2i, to_pos: Vector2i)
signal piece_removed(piece: GamePiece)

@onready var rules_manager: GameRules = $RulesManager
@onready var turn_manager: TurnManager = $RulesManager/TurnManager

@export var board_size: Vector2i = Vector2i(8, 8)  # Default size, can be changed in editor
@export var cell_size: int = 64
@export var font: Font

var squares: Array[Square] = []
var square_lookup: Dictionary = {}
var square_selected: Square = null
var piece_placement: PiecePlacement
var piece_movement: PieceMovement

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_enter_pressed()

func _ready() -> void:
	initialize_board()
	setup_piece_placement()
	setup_piece_movement()

func initialize_board() -> void:
	# Clear existing squares if any
	for square in squares:
		square.queue_free()
	squares.clear()
	square_lookup.clear()
	
	# Create new squares
	var square_scene = preload("res://scenes/square.tscn")
	
	for row in range(board_size.y):
		for col in range(board_size.x):
			var square: Square = square_scene.instantiate()
			add_child(square)
			
			# Set position before configuring other properties
			square.position = Vector2(col * cell_size, row * cell_size)
			
			# Calculate chess notation (A1, B2, etc.)
			var file = char(65 + row) # 65 is ASCII for 'A'
			var rank = str(col + 1)
			var chess_position = file + rank
			
			# Configure square properties after adding to scene tree
			square.setup(
				cell_size,
				(row + col) % 2 == 1,
				font,
				Vector2i(col, row),
				chess_position
			)
			
			# Connect the square's clicked signal
			square.square_clicked.connect(_on_square_clicked)
			
			# Store references
			squares.append(square)
			square_lookup[Vector2i(col, row)] = square

func setup_piece_placement() -> void:
	piece_placement = PiecePlacement.new(self)
	piece_placement.set_rows_per_player(rules_manager.placement_rows_per_player)
	add_child(piece_placement)
	piece_placement.piece_placed.connect(_on_piece_placed)
	
func setup_piece_movement() -> void:
	piece_movement = PieceMovement.new(self)
	add_child(piece_movement)

func _on_square_clicked(square: Square) -> void:
	# Check if it's currently a movement phase
	if not turn_manager.can_move():
		return
		
	if square_selected == null:
		# Only allow selection of squares with pieces belonging to current player
		if square.has_piece() and square.piece.player == turn_manager.current_player:
			square_selected = square
			square.set_selected(true)
			highlight_valid_moves(square.piece)
	else:
		if square == square_selected:
			# Deselect if clicking the same square
			clear_selection()
		elif not square.has_piece():
			# Try to move piece to empty square
			try_move_piece(square_selected.piece, square.board_position)
		else:
			# Clicking a different square with a piece
			clear_selection()
			if square.has_piece() and square.piece.player == turn_manager.current_player:
				square_selected = square
				square.set_selected(true)
				highlight_valid_moves(square.piece)

func try_move_piece(piece: GamePiece, target_pos: Vector2i) -> void:
	# First check if the move is valid
	var move_validation = piece_movement.is_valid_move(piece, target_pos)
	if not move_validation.valid:
		# Handle invalid move
		clear_selection()
		return
		
	# Calculate power cost
	var power_cost = piece_movement.calculate_move_cost(piece, target_pos)

	# Try to execute move
	if piece_movement.execute_move(piece, target_pos):
		emit_signal("piece_moved", piece, piece.current_position, target_pos)
		clear_selection()
	else:
		# Handle failed move
		clear_selection()

func highlight_valid_moves(piece: GamePiece) -> void:
	var possible_moves = piece_movement.get_possible_moves(piece)
	for pos in possible_moves:
		var square = get_square(pos)
		if square:
			square.set_highlighted(true)

func _on_piece_placed(piece: GamePiece, square: Square) -> void:
	emit_signal("piece_placed", piece, square)

func _on_enter_pressed() -> void:
	if not turn_manager.can_place_card():
		turn_manager.next_phase()
	
func get_square(position: Vector2i) -> Square:
	return square_lookup.get(position)

func clear_selection() -> void:
	if square_selected:
		square_selected.set_selected(false)
		square_selected = null

func is_valid_position(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < board_size.x and \
		   position.y >= 0 and position.y < board_size.y

func get_board_size() -> Vector2i:
	return board_size

func set_board_size(new_size: Vector2i) -> void:
	board_size = new_size
	initialize_board()  # Reinitialize the board with new size
