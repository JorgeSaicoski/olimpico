class_name GameBoard extends Node2D

@export var board_size: Vector2i = Vector2i(8, 8)
@export var cell_size: int = 64
@export var font: Font

var squares: Array[Square] = []
var square_lookup: Dictionary = {}
var square_selected: Square = null

func _ready() -> void:
	initialize_board()

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

func chess_to_position(chess_notation: String) -> Vector2i:
	if chess_notation.length() != 2:
		return Vector2i(-1, -1)
	
	var file = chess_notation[0].to_upper().unicode_at(0) - 65 # Convert A-H to 0-7
	var rank = int(chess_notation[1]) - 1 # Convert 1-8 to 0-7
	
	if file < 0 or file >= board_size.y or rank < 0 or rank >= board_size.x:
		return Vector2i(-1, -1)
		
	return Vector2i(rank, file)

func get_square(position: Vector2i) -> Square:
	return square_lookup.get(position)

func clear_selection() -> void:
	if square_selected:
		square_selected.set_selected(false)
		square_selected = null
