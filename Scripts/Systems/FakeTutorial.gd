extends CanvasLayer

signal tutorial_complete

var tasks: Array = [
	["Press  J  to Jump",           "player_jump",    "Registering jump..."],
	["Press  SHIFT  to Sprint",     "player_sprint",  "Enabling sprint..."],
	["Press  Q  to Block",          "player_block",   "Equipping shield..."],
	["Press  E  to talk",       "player_talk",		  "Conmencing speach..."],
	["Press  F  to Roll",           "player_roll",    "Enabling roll..."],
]

var current_task: int     = 0
var task_processing: bool = false
var active: bool          = false  # input is ignored until start() is called

@onready var task_labels: Array[Label] = [
	$Panel/MarginContainer/VBoxContainer/Task1,
	$Panel/MarginContainer/VBoxContainer/Task2,
	$Panel/MarginContainer/VBoxContainer/Task3,
	$Panel/MarginContainer/VBoxContainer/Task4,
	$Panel/MarginContainer/VBoxContainer/Task5,
]
@onready var processing_label: Label = $Panel/MarginContainer/VBoxContainer/Processing

const UNCHECKED: String = "[ ]"
const CHECKED: String   = "[x]"

const COLOR_ACTIVE: Color  = Color(1.0, 1.0, 0.0)
const COLOR_DONE: Color    = Color(0.4, 0.9, 0.4)
const COLOR_PENDING: Color = Color(0.55, 0.55, 0.55)

func _ready() -> void:
	processing_label.visible = false
	_refresh_labels()

# Called by Room2Trigger when the player enters room 2
func start() -> void:
	active = true

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if current_task >= tasks.size():
		return
	if task_processing:
		return

	var action: String = tasks[current_task][1]
	var pressed: bool = false

	if InputMap.has_action(action):
		pressed = event.is_action_pressed(action)
	elif event is InputEventKey:
		pressed = (event as InputEventKey).pressed

	if pressed:
		_begin_check_off()

func _begin_check_off() -> void:
	task_processing = true
	processing_label.text    = tasks[current_task][2]
	processing_label.visible = true

	var delay: float = randf_range(0.5, 1.0)
	await get_tree().create_timer(delay).timeout

	_check_off_current()

func _check_off_current() -> void:
	processing_label.visible = false
	task_processing = false

	var label: Label = task_labels[current_task]
	label.text = CHECKED + "  " + tasks[current_task][0]
	label.add_theme_color_override("font_color", COLOR_DONE)

	current_task += 1
	_refresh_labels()

	if current_task >= tasks.size():
		await get_tree().create_timer(0.8).timeout
		tutorial_complete.emit()

func _refresh_labels() -> void:
	for i: int in range(tasks.size()):
		var label: Label = task_labels[i]
		if i < current_task:
			pass
		elif i == current_task:
			label.text = UNCHECKED + "  " + tasks[i][0]
			label.add_theme_color_override("font_color", COLOR_ACTIVE)
		else:
			label.text = UNCHECKED + "  " + tasks[i][0]
			label.add_theme_color_override("font_color", COLOR_PENDING)
