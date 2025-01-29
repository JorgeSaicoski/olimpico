class_name TurnManager extends Node

signal turn_started(turn_number: int, current_player: String)
signal turn_ended(turn_number: int, current_player: String)
signal phase_changed(phase: String)

enum Phase {
	PLACE_KING,    # Turn 1: Players place kings
	PLACE_CARDS,   # Turn 2: Players place 4 cards each
	MOVEMENT,      # Regular turns: Movement phase
	PLACE_CARD,    # Regular turns: Place 1 card
	ATTACK        # Regular turns: Attack phase
}

var current_turn: int = 1
var current_player: String = "a"
var current_phase: Phase = Phase.PLACE_KING
@onready var rules: GameRules = $".."
var cards_placed_this_turn: int = 0
var total_cards_placed: Dictionary = {"a": 1, "b": 1}  # Start at 1 to account for kings

func _ready() -> void:
	current_player = rules.first_player
	start_turn()

func start_turn() -> void:
	print("Starting turn ", current_turn, " for player ", current_player)
	emit_signal("turn_started", current_turn, current_player)
	
	# Reset cards placed counter at start of turn
	cards_placed_this_turn = 0
	
	# Set initial phase based on turn number
	if current_turn == 1:
		current_phase = Phase.PLACE_KING
	elif current_turn == 2:
		current_phase = Phase.PLACE_CARDS
	else:
		current_phase = Phase.MOVEMENT
	
	emit_signal("phase_changed", Phase.keys()[current_phase])

func end_turn() -> void:
	emit_signal("turn_ended", current_turn, current_player)
	
	# Switch players
	current_player = "b" if current_player == "a" else "a"
	
	# Increment turn counter when player B finishes
	if current_player == "a":
		current_turn += 1
	
	start_turn()

func next_phase() -> void:
	match current_phase:
		Phase.PLACE_KING:
			# After both players place kings, move to next turn
			if current_player == "b":
				end_turn()
			else:
				current_player = "b"
				emit_signal("turn_started", current_turn, current_player)
				
		Phase.PLACE_CARDS:
			# In turn 2, after placing 4 cards
			if cards_placed_this_turn >= 4:
				if current_player == "b":
					end_turn()
				else:
					current_player = "b"
					cards_placed_this_turn = 0
					emit_signal("turn_started", current_turn, current_player)
					
		Phase.MOVEMENT:
			current_phase = Phase.PLACE_CARD
			emit_signal("phase_changed", Phase.keys()[current_phase])
			
		Phase.PLACE_CARD:
			current_phase = Phase.ATTACK
			emit_signal("phase_changed", Phase.keys()[current_phase])
			
		Phase.ATTACK:
			if current_player == "b":
				end_turn()
			else:
				current_player = "b"
				current_phase = Phase.MOVEMENT
				emit_signal("turn_started", current_turn, current_player)
				emit_signal("phase_changed", Phase.keys()[current_phase])

func can_place_card() -> bool:
	if current_turn == 1:
		# Only kings can be placed
		return current_phase == Phase.PLACE_KING
	elif current_turn == 2:
		# Can place 4 cards
		return current_phase == Phase.PLACE_CARDS and cards_placed_this_turn < 4
	else:
		# Can place 1 card during PLACE_CARD phase if haven't reached total limit
		return current_phase == Phase.PLACE_CARD and total_cards_placed[current_player] < 15

func register_card_placed() -> void:
	cards_placed_this_turn += 1
	total_cards_placed[current_player] += 1
	
	if current_turn == 2 and cards_placed_this_turn >= 4:
		next_phase()
	elif current_turn > 2 and current_phase == Phase.PLACE_CARD:
		next_phase()

func get_remaining_cards() -> int:
	return 15 - total_cards_placed[current_player]

func can_move() -> bool:
	return current_phase == Phase.MOVEMENT

func can_attack() -> bool:
	return current_phase == Phase.ATTACK

func is_player_turn(player: String) -> bool:
	return current_player == player
