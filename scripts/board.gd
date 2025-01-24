class_name GameBoard 
extends Node2D

@export var board_size: Vector2i = Vector2i(8, 8)  # Default size of the board
@export var cell_size: int = 64  # Size of each cell in pixels
@export var font: Font # Font
var squares: Array = []  # Array to track board squares and their states
var _square_lookup: Dictionary = {}
var piece_textures: Dictionary = {}  # Dictionary to store piece textures by name
var player_colors = {
	"a": Color(0.4, 0.7, 1, 1.0),  # Soft blue
	"b": Color(1, 0.5, 0.6, 1.0)    # Soft pink/rose
}


func _ready() -> void:
	initialize_board()
	queue_redraw()  # Schedule a redraw to update the board visually

func _draw() -> void:
	# Draw the board
	for square in squares:
		var rect = Rect2(square["position"] * cell_size, Vector2(cell_size, cell_size))
		draw_rect(rect, square["color"])
		if square["piece"] != null:
			var piece = square["piece"]
			var text_color = player_colors[piece["player"]]  # Use the player color from our dictionary
			draw_string(
				font, 
				rect.position + Vector2(cell_size/10, cell_size / 2),  # Adjust position for text alignment
				piece["name"],
				HORIZONTAL_ALIGNMENT_LEFT,  # Add horizontal alignment parameter
				cell_size,  # Width (-1 means no clipping)
				16,  # Font size
				text_color  # Color as the last parameter
			)

func initialize_board() -> void:
	squares.clear()
	_square_lookup.clear()

	for row in range(board_size.y):
		for col in range(board_size.x):
			var square = {
				"position": Vector2i(col, row),
				"color": Color.WHITE if (row + col) % 2 == 0 else Color.BLACK,
				"piece": null
			}
			squares.append(square)
			_square_lookup[square["position"]] = square

	queue_redraw()

func add_piece(piece: Dictionary, square: Dictionary) -> bool:
	if square == {} or square["piece"] != null:
		push_warning("Invalid square or square already occupied")
		return false
	square["piece"] = piece
	queue_redraw()  
	return true

func remove_piece(square: Dictionary) -> Dictionary:
	if square == {} or square["piece"] == null:
		push_warning("Invalid square")
		return {}
	var piece:Dictionary = square["piece"]
	square["piece"] = null
	queue_redraw()  
	return piece

func get_square(mouse_position: Vector2i) -> Dictionary:
	var position = to_local(mouse_position)
	var position_on_board := Vector2i(
		floor(position.x / cell_size), 
		floor(position.y / cell_size)
	)
	
	# Boundary check
	if (position_on_board.x < 0 or position_on_board.x >= board_size.x or 
		position_on_board.y < 0 or position_on_board.y >= board_size.y):
		return {}

	return _square_lookup.get(position_on_board, {})
