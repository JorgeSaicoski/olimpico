class_name Square extends Node2D

signal square_clicked(square)
signal piece_placed(piece: GamePiece)
signal piece_removed(piece: GamePiece)

@export var size: int = 64
@export var is_dark: bool = false
@export var font: Font

var board_position: Vector2i
var chess_position: String
var piece: GamePiece = null
var base_color: Color
var is_selected: bool = false
var highlight_color: Color = Color(0.9, 0.7, 0.2, 1.0)

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
	var square_color = highlight_color if is_selected else base_color
	draw_rect(rect, square_color)
	
	# Draw piece if it exists
	if has_piece():
		var text_color = get_player_color(piece.player)
		var piece_text = piece.piece_name
		
		# Draw piece name
		var font_size = 16
		var text_pos = Vector2(
			size / 2 - font.get_string_size(piece_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x / 2,
			size / 2 - font_size / 2
		)
		
		draw_string(
			font,
			text_pos,
			piece_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			font_size,
			text_color
		)
		
		# Draw HP below piece name
		var hp_text = str(piece.current_hp) + "/" + str(piece.max_hp)
		var hp_font_size = 12
		var hp_pos = Vector2(
			size / 2 - font.get_string_size(hp_text, HORIZONTAL_ALIGNMENT_CENTER, -1, hp_font_size).x / 2,
			size / 2 + hp_font_size
		)
		
		draw_string(
			font,
			hp_pos,
			hp_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			hp_font_size,
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

func set_piece(new_piece: GamePiece) -> bool:
	if new_piece == null and piece == null:
		return false
		
	if piece != null:
		# Disconnect existing piece signals
		if piece.piece_hp_changed.is_connected(_on_piece_hp_changed):
			piece.piece_hp_changed.disconnect(_on_piece_hp_changed)
		if piece.piece_died.is_connected(_on_piece_died):
			piece.piece_died.disconnect(_on_piece_died)
	
	var old_piece = piece
	piece = new_piece
	
	if piece != null:
		# Connect new piece signals
		piece.piece_hp_changed.connect(_on_piece_hp_changed)
		piece.piece_died.connect(_on_piece_died)
		# Update piece position
		piece.current_position = board_position
		piece_placed.emit(piece)
	elif old_piece != null:
		piece_removed.emit(old_piece)
	
	queue_redraw()
	return true

func remove_piece() -> GamePiece:
	var removed_piece = piece
	if removed_piece != null:
		# Disconnect signals
		if removed_piece.piece_hp_changed.is_connected(_on_piece_hp_changed):
			removed_piece.piece_hp_changed.disconnect(_on_piece_hp_changed)
		if removed_piece.piece_died.is_connected(_on_piece_died):
			removed_piece.piece_died.disconnect(_on_piece_died)
		piece_removed.emit(removed_piece)
	
	piece = null
	queue_redraw()
	return removed_piece

func has_piece() -> bool:
	return piece != null

func set_selected(selected: bool) -> void:
	is_selected = selected
	queue_redraw()

func _on_piece_hp_changed(_current_hp: int, _max_hp: int) -> void:
	queue_redraw()

func _on_piece_died() -> void:
	remove_piece()
