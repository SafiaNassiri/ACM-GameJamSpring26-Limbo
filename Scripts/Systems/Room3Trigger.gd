extends Area2D

@onready var room3_manager: Node = $"../==Room3Stuff==/Room3Manager"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	room3_manager.call("enter_room3")

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	room3_manager.call("exit_room3")
