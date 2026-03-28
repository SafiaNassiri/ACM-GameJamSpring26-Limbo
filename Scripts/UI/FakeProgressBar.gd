extends CanvasLayer

signal bar_complete

@onready var status_label: Label         = $Panel/StatusLabel
@onready var bar_fill: PanelContainer    = $Panel/BarContainer/BarFill
@onready var bar_bg: PanelContainer      = $Panel/BarContainer/BarBG

var _progress: float   = 0.0   # 0.0 – 1.0
var _running: bool     = false
var _stalled: bool     = false  # true while stuck at 99%
var _stall_timer: float = 0.0
const STALL_DURATION: float = 15.0
const FILL_SPEED: float     = 0.04   # progress per second

func _ready() -> void:
	visible = false
	_set_fill(0.0)

func start_bar(label_text: String) -> void:
	_progress   = 0.0
	_running    = true
	_stalled    = false
	_stall_timer = 0.0
	status_label.text = label_text
	_set_fill(0.0)
	visible = true

func _process(delta: float) -> void:
	if not _running:
		return

	if _stalled:
		_stall_timer += delta
		if _stall_timer >= STALL_DURATION:
			_stalled  = false
			_running  = false
			status_label.text = "Optimization complete! Press the button to continue."
			_set_fill(1.0)
			await get_tree().create_timer(1.0).timeout
			bar_complete.emit()
		return

	# Normal crawl
	_progress += FILL_SPEED * delta
	if _progress >= 0.99:
		_progress = 0.99
		_stalled  = true
		_stall_timer = 0.0
		status_label.text = "Optimizing room... 99%"

	_set_fill(_progress)
	status_label.text = "Optimizing room... %d%%" % int(_progress * 100)

func _set_fill(t: float) -> void:
	var total_width: float = bar_bg.size.x
	bar_fill.custom_minimum_size.x = total_width * t
