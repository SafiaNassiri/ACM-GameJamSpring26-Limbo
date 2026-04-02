extends Node

## Assign the special Room 3 music track here once the audio file is ready.
@export var room3_music: AudioStream

var _done: bool = false

@onready var progress_bar: Node    = $"../../==UI==/FakeProgressBar"
@onready var lying_button: Node    = $"../LyingButton"
@onready var real_door: Node       = $"../RealDoor"

func _ready() -> void:
	(real_door as TileMapLayer).enabled = true
	(lying_button as Area2D).visible    = true

	progress_bar.connect("bar_complete", _on_bar_complete)
	lying_button.connect("player_stepped_on", _on_button_stepped)

func _on_button_stepped() -> void:
	if _done:
		return
	progress_bar.call("start_bar")

func _on_bar_complete() -> void:
	_done = true
	(real_door as TileMapLayer).enabled = false
	progress_bar.call("hide_bar")

func enter_room3() -> void:
	AudioManager.enter_room3_music(room3_music)

func exit_room3() -> void:
	AudioManager.exit_room3_music()
