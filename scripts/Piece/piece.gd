class_name GamePiece extends Node2D

signal piece_hp_changed(current_hp: int, max_hp: int)
signal piece_died()

# Basic piece attributes
@export var piece_name: String = ""
@export var player: String = ""  # "a" or "b"

# Combat stats
@export var max_hp: int = 10
@export var attack_power: int = 2
@export var defense: int = 1

# Movement and action costs
@export var movement_cost: int = 1  # Power cost per square moved
@export var attack_cost: int = 4    # Power cost to perform an attack

@export var is_range: bool = false
@export var range: int = 4


# Current state
var current_hp: int
var current_position: Vector2i
var is_visible_to_opponent: bool = false

# History tracking
var placement_turn: int = -1
var visited_squares: Array[Vector2i] = []
var attacked_pieces: Array[Dictionary] = []  # [{piece_id: str, turn: int}]
var moves_this_turn: Array[Vector2i] = []

func _ready() -> void:
	current_hp = max_hp

func initialize(init_name: String, init_player: String, pos: Vector2i, turn: int) -> void:
	piece_name = init_name
	player = init_player
	current_position = pos
	placement_turn = turn
	visited_squares.append(pos)

func take_damage(damage: int) -> bool:
	var actual_damage = max(damage - defense, 0)
	current_hp -= actual_damage
	
	emit_signal("piece_hp_changed", current_hp, max_hp)
	
	if current_hp <= 0:
		emit_signal("piece_died")
		return true  # Piece is defeated
	
	return false  # Piece survives

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("piece_hp_changed", current_hp, max_hp)

func can_move_to(new_pos: Vector2i, available_power: int) -> bool:
	# Calculate Manhattan distance
	var distance = abs(new_pos.x - current_position.x) + abs(new_pos.y - current_position.y)
	var power_needed = distance * movement_cost
	return power_needed <= available_power

func move_to(new_pos: Vector2i, current_turn: int) -> int:
	var distance = abs(new_pos.x - current_position.x) + abs(new_pos.y - current_position.y)
	var power_used = distance * movement_cost
	
	current_position = new_pos
	visited_squares.append(new_pos)
	moves_this_turn.append(new_pos)
	
	return power_used

func can_attack(target_piece: GamePiece, available_power: int) -> bool:
	if available_power < attack_cost:
		return false
		
	# Add any additional attack validation logic here
	return true

func attack(target_piece: GamePiece, current_turn: int) -> bool:
	var was_defeated = target_piece.take_damage(attack_power)
	
	# Record the attack
	attacked_pieces.append({
		"piece_id": target_piece.piece_name,
		"turn": current_turn
	})
	
	return was_defeated

func start_turn() -> void:
	moves_this_turn.clear()

func set_visibility(visible: bool) -> void:
	is_visible_to_opponent = visible
	# Add any visibility change logic here

func get_movement_history() -> Array[Vector2i]:
	return visited_squares.duplicate()

func get_attack_history() -> Array[Dictionary]:
	return attacked_pieces.duplicate()

func save_state() -> Dictionary:
	return {
		"name": piece_name,
		"player": player,
		"position": {"x": current_position.x, "y": current_position.y},
		"hp": current_hp,
		"placement_turn": placement_turn,
		"visited_squares": visited_squares,
		"attacked_pieces": attacked_pieces,
		"is_visible": is_visible_to_opponent
	}

func load_state(state: Dictionary) -> void:
	piece_name = state.get("name", "")
	player = state.get("player", "")
	current_position = Vector2i(state.get("position", {}).get("x", 0), 
	state.get("position", {}).get("y", 0))
	current_hp = state.get("hp", max_hp)
	placement_turn = state.get("placement_turn", -1)
	visited_squares = state.get("visited_squares", [])
	attacked_pieces = state.get("attacked_pieces", [])
	is_visible_to_opponent = state.get("is_visible", false)
