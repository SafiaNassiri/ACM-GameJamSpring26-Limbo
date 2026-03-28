extends Area2D

signal button_pressed_n(total: int)

var _active: bool      = false
var _press_mode: bool  = false  # false = troll mode, true = 30-press mode
var _total_presses: int = 0
var _troll_presses: int = 0

# Sarcastic lines shown in troll mode on each press
const TROLL_LINES: Array[String] = [
	"",          # press 1 — silence
	"",          # press 2 — silence
	"...",       # press 3 — triggers bar reset (handled in manager)
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func activate() -> void:
	_active       = true
	_press_mode   = false
	_troll_presses = 0

func deactivate() -> void:
	_active = false

# Called by Room3Manager after checkpoint is saved
func set_press_mode() -> void:
	_active      = true
	_press_mode  = true
	_total_presses = 0

func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	if not body.is_in_group("player"):
		return

	_total_presses += 1
	button_pressed_n.emit(_total_presses)

	if not _press_mode:
		_troll_presses += 1
		# Sarcastic feedback for first two presses
		if _troll_presses == 1:
			DialogueManager.start_conversation("button_press_1")
		elif _troll_presses == 2:
			DialogueManager.start_conversation("button_press_2")
		# Press 3+ is handled by Room3Manager (_on_button_pressed)

	else:
		# 30-press mode sarcasm handled by Room3Manager
		pass

func _on_body_exited(_body: Node2D) -> void:
	pass  # nothing needed on exit
