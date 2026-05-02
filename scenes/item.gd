extends Area2D

enum ItemType { COFFEE, GUN, HEART }

@export var item_type: ItemType = ItemType.HEART

const COFFEE_TEX = preload("res://assets/items/coffee_box.png")
const GUN_TEX    = preload("res://assets/items/gun_box.png")
const HEART_TEX  = preload("res://assets/items/heart.png")

func _ready() -> void:
	match item_type:
		ItemType.COFFEE:
			$Sprite2D.texture = COFFEE_TEX
		ItemType.GUN:
			$Sprite2D.texture = GUN_TEX
		ItemType.HEART:
			$Sprite2D.texture = HEART_TEX
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_item_effect"):
		body.apply_item_effect(item_type)
		queue_free()
