extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()
	_update_animation(input_dir)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		$AnimatedSprite2D.stop()
		return

	var direction_name := _get_direction_name(dir)
	$AnimatedSprite2D.play(direction_name)

func _get_direction_name(dir: Vector2) -> StringName:
	var angle := dir.angle()
	# Godot angles: right=0, down=PI/2, left=PI/-PI, up=-PI/2
	if angle < -7 * PI / 8 or angle > 7 * PI / 8:
		return &"W"
	if angle > PI / 8 and angle <= 3 * PI / 8:
		return &"SE"
	if angle > 3 * PI / 8 and angle <= 5 * PI / 8:
		return &"S"
	if angle > 5 * PI / 8 and angle <= 7 * PI / 8:
		return &"SW"
	if angle < -PI / 8 and angle >= -3 * PI / 8:
		return &"NE"
	if angle < -3 * PI / 8 and angle >= -5 * PI / 8:
		return &"N"
	if angle < -5 * PI / 8 and angle >= -7 * PI / 8:
		return &"NW"
	return &"E"
