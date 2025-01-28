class_name Square extends Node2D

signal square_clicked(square)

@export var size: int = 64
@export var is_dark: bool = false
@export var font: Font

var board_position: Vector2i
var chess_position: String
var piece: Dictionary = {}
var base_color: Color
var is_selected: bool = false

func _ready() -> void:
	base_color = Color.BLACK if is_dark else Color.WHITE
	queue_redraw()

func setup(new_size: int, dark: bool, new_font: Font, pos: Vector2i, chess_pos: String) -> void:
	size = new_size
	is_dark = dark
	font = new_font
	board_position = pos
	chess_position = chess_pos
	base_color = Color.BLACK if is_dark else Color.WHITE
	queue_redraw()

func _draw() -> void:
	# Draw the square background
	var rect = Rect2(Vector2.ZERO, Vector2(size, size))
	
	# Determine square color based on selection state
	var square_color = base_color
	if is_selected:
		square_color = Color(0.9, 0.7, 0.2, 1.0) # Highlight color for selected square
	
	draw_rect(rect, square_color)
	
	# Draw piece if it exists
	if not piece.is_empty():
		var text_color = get_player_color(piece.get("player", ""))
		var text = piece.get("name", "")
		var font_size = 16
		var text_pos = Vector2(
			size / 2 - font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x / 2,
			size / 2 + font_size / 2
		)
		
		draw_string(
			font,
			text_pos,
			text,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			font_size,
			text_color
		)
	
	# Draw chess position
	var position_font_size = 10
	draw_string(
		font,
		Vector2(2, size - 2),
		chess_position,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		position_font_size,
		Color.GRAY
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos = get_local_mouse_position()
			var rect = Rect2(Vector2.ZERO, Vector2(size, size))
			if rect.has_point(local_pos):
				square_clicked.emit(self)

func get_player_color(player: String) -> Color:
	var colors = {
		"a": Color(0.4, 0.7, 1, 1.0),  # Soft blue
		"b": Color(1, 0.5, 0.6, 1.0)   # Soft pink/rose
	}
	return colors.get(player, Color.WHITE)

func set_piece(new_piece: Dictionary) -> bool:
	if new_piece.is_empty() and piece.is_empty():
		return false
	piece = new_piece
	queue_redraw()
	return true

func remove_piece() -> Dictionary:
	var removed_piece = piece
	piece = {}
	queue_redraw()
	return removed_piece

func has_piece() -> bool:
	return not piece.is_empty()

func set_selected(selected: bool) -> void:
	is_selected = selected
	queue_redraw()
