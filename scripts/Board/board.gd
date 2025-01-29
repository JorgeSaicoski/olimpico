class_name GameBoard extends Node2D

signal piece_placed(piece: GamePiece, square: Square)

@onready var rules_manager: GameRules = $RulesManager

@export var board_size: Vector2i = Vector2i(8, 8)  # Default size, can be changed in editor
@export var cell_size: int = 64
@export var font: Font

var squares: Array[Square] = []
var square_lookup: Dictionary = {}
var square_selected: Square = null
var piece_placement: PiecePlacement

func _ready() -> void:
	initialize_board()
	setup_piece_placement()

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

func _on_square_clicked(square: Square) -> void:
	if square_selected == null:
		# Only allow selection of squares with pieces
		if square.has_piece():
			square_selected = square
			square.set_selected(true)
	else:
		if square == square_selected:
			# Deselect if clicking the same square
			square_selected.set_selected(false)
			square_selected = null
		elif not square.has_piece():
			# Move piece to empty square
			var piece = square_selected.remove_piece()
			square.set_piece(piece)
			square_selected.set_selected(false)
			square_selected = null
		else:
			# Clicking a different square with a piece
			square_selected.set_selected(false)
			if square.has_piece():
				square.set_selected(true)
				square_selected = square

func _on_piece_placed(piece: GamePiece, square: Square) -> void:
	emit_signal("piece_placed", piece, square)

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
