extends Node2D

var _age: float = 0.0
var _duration: float = 0.4

func _process(delta: float) -> void:
	_age += delta
	if _age >= _duration:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var t: float = _age / _duration
	var rings: int = 3
	for i in range(rings):
		var ring_t: float = t - i * 0.15
		if ring_t < 0.0 or ring_t > 1.0:
			continue
		var radius: float = ring_t * 40.0
		var alpha: float = 1.0 - ring_t
		draw_arc(Vector2.ZERO, radius, 0, TAU, 16, Color(1.0, 0.6, 0.1, alpha * 0.8), 2.0, true)
	# Center flash
	var flash_alpha: float = max(0.0, 1.0 - t * 2.5)
	draw_circle(Vector2.ZERO, 12.0 * t + 4.0, Color(1.0, 0.8, 0.2, flash_alpha * 0.6))
