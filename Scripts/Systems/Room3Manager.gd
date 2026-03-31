extends Node

var _done: bool = false

@onready var progress_bar: Node    = $"../../==UI==/FakeProgressBar"
@onready var lying_button: Node    = $"../LyingButton"
@onready var real_door: Node       = $"../RealDoor"
@onready var fake_door: Node       = $"../FakeDoor"
@onready var checkpoint_flag: Node = $"../CheckpointFlag"

func _ready() -> void:
	(real_door as TileMapLayer).enabled = true
	(lying_button as Area2D).visible    = true
	(checkpoint_flag as Sprite2D).visible = false

	# Fake door is no longer part of the puzzle — keep it hidden.
	var fake_tile: TileMapLayer = fake_door.get_node("TileMapLayer") as TileMapLayer
	fake_tile.visible = false
	fake_tile.enabled = false
	var fake_area: Area2D = fake_door.get_node("Area2D") as Area2D
	fake_area.get_node("CollisionShape2D").set_deferred("disabled", true)

	progress_bar.connect("bar_complete", _on_bar_complete)
	lying_button.connect("player_stepped_on", _on_button_stepped)

func _on_button_stepped() -> void:
	if _done:
		return
	progress_bar.call("start_bar")

func _on_bar_complete() -> void:
	_done = true
	(real_door as TileMapLayer).enabled = false

func hide_progress_bar() -> void:
	if not _done:
		progress_bar.call("hide_bar")
