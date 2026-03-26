extends CanvasLayer

signal tutorial_complete

var tasks: Array = [
	["Press  SPACE  to Jump",          "ui_accept",      "Registering jump..."],
	["Press  SHIFT  to Sprint",        "player_sprint",  "Enabling sprint..."],
	["Press  F  to Roll",              "player_roll",    "Calibrating roll..."],
	["Press  Q  to Block",             "player_block",   "Equipping shield..."],
	["Press  E  to Open Inventory",    "player_interact","Loading inventory..."],
]

var current_task: int   = 0
var is_processing: bool = false

@onready var task_labels: Array[Label] = [
	$Panel/VBox/Task0,
	$Panel/VBox/Task1,
	$Panel/VBox/Task2,
	$Panel/VBox/Task3,
	$Panel/VBox/Task4,
]
@onready var processing_label: Label = $Panel/Processing

const UNCHECKED: String = "[ ]"
const CHECKED: String   = "[x]"

const COLOR_ACTIVE: Color  = Color(1.0, 1.0, 0.0)    # yellow  – current task
const COLOR_DONE: Color    = Color(0.4, 0.9, 0.4)    # green   – completed
const COLOR_PENDING: Color = Color(0.55, 0.55, 0.55) # grey    – not yet reached

func _ready() -> void:
	processing_label.visible = false
	_refresh_labels()

func _unhandled_input(event: InputEvent) -> void:
	if current_task >= tasks.size():
		return
	if is_processing:
		return

	var action: String = tasks[current_task][1]
	var pressed: bool = false

	if InputMap.has_action(action):
		pressed = event.is_action_pressed(action)
	elif event is InputEventKey:
		# Fallback: accept any key press if action isn't mapped yet.
		# Remove this elif once all actions are in the Input Map.
		pressed = (event as InputEventKey).pressed

	if pressed:
		_begin_check_off()

func _begin_check_off() -> void:
	is_processing = true
	processing_label.text    = tasks[current_task][2]
	processing_label.visible = true

	var delay: float = randf_range(0.5, 1.0)
	await get_tree().create_timer(delay).timeout

	_check_off_current()

func _check_off_current() -> void:
	processing_label.visible = false
	is_processing = false

	var label: Label = task_labels[current_task] as Label
	label.text = CHECKED + "  " + tasks[current_task][0]
	label.add_theme_color_override("font_color", COLOR_DONE)

	current_task += 1
	_refresh_labels()

	if current_task >= tasks.size():
		await get_tree().create_timer(0.8).timeout
		tutorial_complete.emit()

func _refresh_labels() -> void:
	for i: int in range(tasks.size()):
		var label: Label = task_labels[i] as Label
		if i < current_task:
			pass  # already styled green above, leave it alone
		elif i == current_task:
			label.text = UNCHECKED + "  " + tasks[i][0]
			label.add_theme_color_override("font_color", COLOR_ACTIVE)
		else:
			label.text = UNCHECKED + "  " + tasks[i][0]
			label.add_theme_color_override("font_color", COLOR_PENDING)
