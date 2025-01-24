extends Camera2D

# Speed of the camera movement
@export var move_speed: float = 400.0

func _process(delta: float) -> void:
	# Get input for movement
	var direction = Vector2.ZERO
	if Input.is_key_pressed(KEY_A): 
		direction.x -= 1
	if Input.is_key_pressed(KEY_D): 
		direction.x += 1
	if Input.is_key_pressed(KEY_W): 
		direction.y -= 1
	if Input.is_key_pressed(KEY_S): 
		direction.y += 1
	
	# Normalize the direction to ensure consistent speed
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# Move the camera
	position += direction * move_speed * delta
