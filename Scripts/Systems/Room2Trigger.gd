extends Area2D

var _triggered: bool = false

@onready var tutorial_ui: Node = $"../==UI==/TutorialUI"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return

	_triggered = true

	# Show the UI and activate input listening
	(tutorial_ui as CanvasLayer).visible = true
	tutorial_ui.call("start")
