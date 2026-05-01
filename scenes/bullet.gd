extends Area2D

@export var speed: float = 400.0
@export var lifetime: float = 2.0
@export var damage: float = 1.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 3.0, Color.YELLOW)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
