extends Node2D

@onready var door:         StaticBody2D = $Door
@onready var tutorial_ui:  CanvasLayer  = $TutorialUI
@onready var troll_label:  Label        = $TrollLabel

# Troll messages — pick one at random for replayability
const TROLL_MESSAGES: Array = [
	"Tutorial complete!\n\nYou are now fully prepared.\n\n...for a completely different game. :)",
	"Great work! You've mastered all the controls.\n\nNone of which exist in this game.",
	"Congratulations! Your jump, sprint, roll, block,\nand inventory are all working perfectly.\n\nJust kidding — none of those are real.",
]

func _ready() -> void:
	troll_label.visible = false

	# Door starts red (locked)
	door.get_node("Sprite2D").modulate = Color(1.0, 0.3, 0.3)

	# Wire up the tutorial completion signal
	tutorial_ui.tutorial_complete.connect(_on_tutorial_complete)

func _on_tutorial_complete() -> void:
	# Flash the door green (unlocked)
	door.get_node("Sprite2D").modulate = Color(0.3, 1.0, 0.3)

	# Disable the door's collision so the player can walk through
	door.get_node("CollisionShape2D").disabled = true

	# Pick a random troll message
	troll_label.text    = TROLL_MESSAGES[randi() % TROLL_MESSAGES.size()]
	troll_label.visible = true

	# Wait then move to the next level
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://scenes/Level3.tscn")  # update path as needed
