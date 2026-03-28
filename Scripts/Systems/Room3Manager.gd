extends Node

enum Phase {
	IDLE,           # waiting for player to enter room
	BAR_RUNNING,    # progress bar ticking up
	BUTTON_ACTIVE,  # bar done, button is live
	CHECKPOINT,     # checkpoint roulette happening
	PRESSING,       # player pressing button toward 30
	FAKE_DOOR,      # fake door revealed
	DONE            # real door revealed
}

var phase: Phase = Phase.IDLE
var button_presses: int = 0
var checkpoint_saved: bool = false

@onready var progress_bar: Node    = $"../FakeProgressBar"
@onready var lying_button: Node    = $"../LyingButton"
@onready var checkpoint_flag: Node = $"../CheckpointFlag"
@onready var fake_door: Node       = $"../FakeDoor"
@onready var real_door: Node       = $"../RealDoor"
@onready var room3_entrance: Node  = $"../Room3Entrance"
@onready var player: Node          = $"../Player"

func _ready() -> void:
	# Everything hidden at start
	(checkpoint_flag as Sprite2D).visible = false
	(fake_door as Area2D).visible         = false
	(real_door as Area2D).visible         = false
	(lying_button as Area2D).visible      = false

	# Connect signals from child systems
	progress_bar.connect("bar_complete", _on_bar_complete)
	lying_button.connect("button_pressed_n", _on_button_pressed)
	fake_door.connect("player_entered", _on_fake_door_entered)

# Called by Room3Trigger when player enters room 3
func start() -> void:
	if phase != Phase.IDLE:
		return
	phase = Phase.BAR_RUNNING
	progress_bar.call("start_bar", "Optimizing room...")

func _on_bar_complete() -> void:
	if phase == Phase.BAR_RUNNING:
		# First completion 
		phase = Phase.BUTTON_ACTIVE
		(lying_button as Area2D).visible = true
		lying_button.call("activate")

	elif phase == Phase.BUTTON_ACTIVE:
		# Bar restarted by button troll
		_do_checkpoint_roulette()

	elif phase == Phase.CHECKPOINT and not checkpoint_saved:
		# Fake checkpoint
		_do_checkpoint_roulette()

func _do_checkpoint_roulette() -> void:
	phase = Phase.CHECKPOINT
	var roll: float = randf()
	if roll <= 0.8:
		# Real checkpoint
		checkpoint_saved = true
		(checkpoint_flag as Sprite2D).visible = true
		DialogueManager.start_conversation("checkpoint_real")
		await DialogueManager.dialogue_ended
		phase = Phase.PRESSING
		lying_button.call("set_press_mode")  # switch to 30-press mode
	else:
		# Fake checkpoint 
		checkpoint_saved = false
		await get_tree().create_timer(1.5).timeout
		progress_bar.call("start_bar", "Recalibrating... sorry about that.")

func _on_button_pressed(total: int) -> void:
	if phase == Phase.BUTTON_ACTIVE:
		# First few presses 
		if total >= 3:
			lying_button.call("deactivate")
			progress_bar.call("start_bar", "Recalibrating... sorry about that.")
			phase = Phase.BUTTON_ACTIVE  # bar_complete will handle next step
		return

	if phase == Phase.PRESSING:
		# Sarcastic messages every 10 presses
		if total == 10:
			DialogueManager.start_conversation("press_hint_10")
		elif total == 20:
			DialogueManager.start_conversation("press_hint_20")
		elif total >= 30:
			# Reveal fake door
			phase = Phase.FAKE_DOOR
			(fake_door as Area2D).visible = true
			DialogueManager.start_conversation("door_revealed")

func _on_fake_door_entered() -> void:
	if phase != Phase.FAKE_DOOR:
		return

	# Teleport player back to room 3 entrance
	DialogueManager.start_conversation("fake_door_troll")
	await DialogueManager.dialogue_ended

	(player as CharacterBody2D).global_position = (room3_entrance as Marker2D).global_position
	(fake_door as Area2D).visible = false

	# Now reveal the real door somewhere unexpected
	phase = Phase.DONE
	(real_door as Area2D).visible = true
	DialogueManager.start_conversation("real_door_hint")
