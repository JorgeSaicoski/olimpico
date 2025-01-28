class_name GameBoard extends Node2D

@export var board_size: Vector2i = Vector2i(8, 8)
@export var cell_size: int = 64
@export var font: Font

var squares: Array[Square] = []
var square_lookup: Dictionary = {}

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
			# Convert col to letter (0 = A, 1 = B, etc.)
			var file = char(65 + col) # 65 is ASCII for 'A'
			# Chess notation starts from bottom, so we invert the row number
			var rank = str(board_size.y - row)
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

func add_piece(piece: Dictionary, position: Vector2i) -> bool:
	var square = square_lookup.get(position)
	if square == null:
		return false
	return square.set_piece(piece)

func remove_piece(position: Vector2i) -> Dictionary:
	var square = square_lookup.get(position)
	if square == null:
		return {}
	return square.remove_piece()

func _on_square_clicked(square: Square) -> void:
	# Handle square clicks here
	# You can emit a signal to notify parent nodes if needed
	pass

func get_square(position: Vector2i) -> Square:
	return square_lookup.get(position)

# Helper function to convert chess notation to board position
func chess_to_position(chess_notation: String) -> Vector2i:
	if chess_notation.length() != 2:
		return Vector2i(-1, -1)
	
	var file = chess_notation[0].to_upper().unicode_at(0) - 65 # Convert A-H to 0-7
	var rank = board_size.y - int(chess_notation[1]) # Convert 1-8 to 7-0
	
	if file < 0 or file >= board_size.x or rank < 0 or rank >= board_size.y:
		return Vector2i(-1, -1)
		
	return Vector2i(file, rank)
