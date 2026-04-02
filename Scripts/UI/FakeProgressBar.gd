extends CanvasLayer

signal bar_complete

@onready var status_label: Label      = $Panel/StatusLabel
@onready var bar_fill: PanelContainer = $Panel/BarBG/BarFill
@onready var bar_bg: PanelContainer   = $Panel/BarBG

var _progress: float = 0.0
var _active: bool    = false

## Drain per second at 0% progress.
const BASE_DRAIN: float     = 0.04
## At 100% progress the drain rate is BASE_DRAIN * DRAIN_MULTIPLIER.
## Keep pressing faster and faster to counteract the escalating drain.
const DRAIN_MULTIPLIER: float = 6.0
## Progress added per key press.
const FILL_PER_PRESS: float = 0.04

func _ready() -> void:
	visible = false
	await get_tree().process_frame
	_set_fill(0.0)

func start_bar() -> void:
	if _active:
		return
	_progress = 0.0
	_active   = true
	_set_fill(0.0)
	visible = true
	status_label.text = "0%"
	AudioManager.set_bar_active(true)

func _process(delta: float) -> void:
	if not _active:
		return

	if Input.is_action_just_pressed("player_interact"):
		_progress += FILL_PER_PRESS
		AudioManager.notify_space_press()

	# Check completion before applying drain so 100% is reachable.
	if _progress >= 1.0:
		_active   = false
		_progress = 1.0
		_set_fill(1.0)
		status_label.text = "Done."
		AudioManager.set_bar_active(false)
		await get_tree().create_timer(0.5).timeout
		bar_complete.emit()
		return

	# Drain escalates linearly with progress — hardest near the end.
	var drain_rate: float = BASE_DRAIN * (1.0 + (DRAIN_MULTIPLIER - 1.0) * _progress)
	_progress = max(0.0, _progress - drain_rate * delta)

	_set_fill(_progress)
	_update_label()

func _update_label() -> void:
	var pct: int = int(_progress * 100)
	if pct >= 95:
		status_label.text = "SO CLOSE. %d%%" % pct
	elif pct >= 70:
		status_label.text = "Almost... %d%%" % pct
	elif pct >= 40:
		status_label.text = "Keep going... %d%%" % pct
	else:
		status_label.text = "Press SPACE %d%%" % pct

func _set_fill(t: float) -> void:
	var total_width: float = bar_bg.size.x
	bar_fill.custom_minimum_size.x = total_width * t

func hide_bar() -> void:
	visible   = false
	_active   = false
	_progress = 0.0
	_set_fill(0.0)
	AudioManager.set_bar_active(false)
