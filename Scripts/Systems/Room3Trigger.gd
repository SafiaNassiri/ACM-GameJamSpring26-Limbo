extends Area2D

var _triggered: bool = false

@onready var room3_manager: Node = $"../==Room3Stuff==/Room3Manager"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	_triggered = true
	room3_manager.call("start")

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	room3_manager.call("hide_progress_bar")
