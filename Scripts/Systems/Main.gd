extends Node2D

@onready var bridge: Node      = $"==TitleLayers==/Bridge"
@onready var water: Node       = $"==TitleLayers==/Water"
@onready var tutorial_ui: Node = $"==UI==/TutorialUI"

const APOLOGY_SCRIPT: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "",
			"line": "Oh.",
			"auto_advance": true,
			"delay": 1.2,
			"next": "oops"
		},
		"oops": {
			"speaker": "",
			"line": "Oops.",
			"auto_advance": true,
			"delay": 1.4,
			"next": "wrong_game"
		},
		"wrong_game": {
			"speaker": "",
			"line": "Those are the controls for the wrong game....",
			"auto_advance": true,
			"delay": 2.2,
			"next": "bridge_line"
		},
		"bridge_line": {
			"speaker": "",
			"line": "Anyway! Here's a bridge, buddy. :)",
			"next": "END"
		},
	}
}

func _ready() -> void:
	# Bridge starts hidden
	(bridge as TileMapLayer).visible = false

	(tutorial_ui as CanvasLayer).visible = false

	# Register the apology dialogue
	DialogueManager.register_script("bridge_apology", APOLOGY_SCRIPT)

	# Listen for the fake tutorial finishing
	tutorial_ui.connect("tutorial_complete", _on_tutorial_complete)

func _on_tutorial_complete() -> void:
	(tutorial_ui as CanvasLayer).visible = false

	await get_tree().create_timer(0.6).timeout

	DialogueManager.start_conversation("bridge_apology")

	await DialogueManager.dialogue_ended

	_reveal_bridge()

func _reveal_bridge() -> void:
	# Show the bridge visually
	(bridge as TileMapLayer).visible = true
	(water as TileMapLayer).enabled = false
