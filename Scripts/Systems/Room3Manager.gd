extends Node

const CHECKPOINT_REAL: Dictionary = {
	"nodes": { "start": { "speaker": "", "line": "Checkpoint saved!", "auto_advance": true, "delay": 1.5, "next": "END" } }
}
const PRESS_HINT_10: Dictionary = {
	"nodes": { "start": { "speaker": "", "line": "Getting warmer...", "auto_advance": true, "delay": 1.5, "next": "END" } }
}
const PRESS_HINT_20: Dictionary = {
	"nodes": { "start": { "speaker": "", "line": "Bold strategy. Keep going.", "auto_advance": true, "delay": 1.5, "next": "END" } }
}
const DOOR_REVEALED: Dictionary = {
	"nodes": { "start": { "speaker": "", "line": "Oh look. A door.", "auto_advance": true, "delay": 2.0, "next": "END" } }
}
const FAKE_DOOR_TROLL: Dictionary = {
	"nodes": {
		"start":    { "speaker": "", "line": "Room 4 is currently under construction.", "auto_advance": true, "delay": 2.0, "next": "apologize" },
		"apologize":{ "speaker": "", "line": "Please enjoy Room 3 again. :)", "auto_advance": true, "delay": 2.0, "next": "END" }
	}
}
const REAL_DOOR_HINT: Dictionary = {
	"nodes": { "start": { "speaker": "", "line": "The real door is around here somewhere. Probably.", "auto_advance": true, "delay": 2.5, "next": "END" } }
}

const BUTTON_PRESS_1: Dictionary = {
	"nodes": { "start": { "speaker": "", "line": "...", "auto_advance": true, "delay": 1.0, "next": "END" } }
}
const BUTTON_PRESS_2: Dictionary = {
	"nodes": { "start": { "speaker": "", "line": "Hm.", "auto_advance": true, "delay": 1.0, "next": "END" } }
}

enum Phase {
	IDLE, BAR_RUNNING, BUTTON_ACTIVE, CHECKPOINT, PRESSING, FAKE_DOOR, DONE
}

var phase: Phase = Phase.IDLE
var button_presses: int = 0
var checkpoint_saved: bool = false

@onready var progress_bar: Node    = $"../../==UI==/FakeProgressBar"
@onready var lying_button: Node    = $"../LyingButton"
@onready var checkpoint_flag: Node = $"../CheckpointFlag"
@onready var fake_door: Node       = $"../FakeDoor"
@onready var real_door: Node       = $"../RealDoor"
@onready var room3_entrance: Node  = $"../Room3Entrance"
@onready var player: Node          = $"../../Player"

func _ready() -> void:	
	_set_fake_door_visible(false)
	(real_door as TileMapLayer).enabled = true
	(checkpoint_flag as Sprite2D).visible = false
	(lying_button as Area2D).visible = false

	progress_bar.connect("bar_complete", _on_bar_complete)
	lying_button.connect("button_pressed_n", _on_button_pressed)

	var fake_door_area: Area2D = fake_door.get_node("Area2D") as Area2D
	fake_door_area.connect("player_entered", _on_fake_door_entered)

	DialogueManager.register_script("button_press_1", BUTTON_PRESS_1)
	DialogueManager.register_script("button_press_2", BUTTON_PRESS_2)
	DialogueManager.register_script("checkpoint_real", CHECKPOINT_REAL)
	DialogueManager.register_script("press_hint_10",   PRESS_HINT_10)
	DialogueManager.register_script("press_hint_20",   PRESS_HINT_20)
	DialogueManager.register_script("door_revealed",   DOOR_REVEALED)
	DialogueManager.register_script("fake_door_troll", FAKE_DOOR_TROLL)
	DialogueManager.register_script("real_door_hint",  REAL_DOOR_HINT)

func _set_fake_door_visible(visible: bool) -> void:
	# Toggle the tile graphic
	var tile: TileMapLayer = fake_door.get_node("TileMapLayer") as TileMapLayer
	tile.visible = visible
	tile.enabled = visible
	# Toggle the trigger area
	var area: Area2D = fake_door.get_node("Area2D") as Area2D
	area.get_node("CollisionShape2D").set_deferred("disabled", not visible)

func start() -> void:
	if phase != Phase.IDLE:
		return
	phase = Phase.BAR_RUNNING
	progress_bar.call("start_bar", "Optimizing room...")

func _on_bar_complete() -> void:
	if phase == Phase.BAR_RUNNING:
		phase = Phase.BUTTON_ACTIVE
		(lying_button as Area2D).visible = true
		lying_button.call("activate")
	elif phase == Phase.BUTTON_ACTIVE:
		_do_checkpoint_roulette()
	elif phase == Phase.CHECKPOINT and not checkpoint_saved:
		_do_checkpoint_roulette()

func _do_checkpoint_roulette() -> void:
	phase = Phase.CHECKPOINT
	var roll: float = randf()
	if roll <= 0.8:
		checkpoint_saved = true
		(checkpoint_flag as Sprite2D).visible = true
		DialogueManager.start_conversation("checkpoint_real")
		await DialogueManager.dialogue_ended
		phase = Phase.PRESSING
		lying_button.call("set_press_mode")
	else:
		checkpoint_saved = false
		await get_tree().create_timer(1.5).timeout
		progress_bar.call("start_bar", "Recalibrating... sorry about that.")

func _on_button_pressed(total: int) -> void:
	if phase == Phase.BUTTON_ACTIVE:
		if total >= 3:
			lying_button.call("deactivate")
			progress_bar.call("start_bar", "Recalibrating... sorry about that.")
			phase = Phase.BUTTON_ACTIVE
		return

	if phase == Phase.PRESSING:
		if total == 10:
			DialogueManager.start_conversation("press_hint_10")
		elif total == 20:
			DialogueManager.start_conversation("press_hint_20")
		elif total >= 30:
			phase = Phase.FAKE_DOOR
			_set_fake_door_visible(true)
			DialogueManager.start_conversation("door_revealed")

func _on_fake_door_entered() -> void:
	if phase != Phase.FAKE_DOOR:
		return
	DialogueManager.start_conversation("fake_door_troll")
	await DialogueManager.dialogue_ended

	(player as CharacterBody2D).global_position = (room3_entrance as Marker2D).global_position
	_set_fake_door_visible(false)

	# Reveal real door by disabling the wall TileMapLayer (creates walkable gap)
	phase = Phase.DONE
	(real_door as TileMapLayer).enabled = false
	DialogueManager.start_conversation("real_door_hint")

func hide_progress_bar() -> void:
	progress_bar.call("hide_bar")
