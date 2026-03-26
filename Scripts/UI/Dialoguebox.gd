extends PanelContainer

@onready var speaker_label: Label          = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SpeakerLabel
@onready var line_label: RichTextLabel     = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/LineLabel
@onready var choices_container: VBoxContainer = $MarginContainer/VBoxContainer/ChoicesContainer

# Typewriter
var _full_text: String = ""
var _visible_chars: int = 0
var _typewriter_speed: float = 0.03   # seconds per character
var _typewriter_timer: float = 0.0
var _typing: bool = false
var _waiting_for_advance: bool = false

func _ready() -> void:
	hide()
	DialogueManager.line_ready.connect(_on_line_ready)
	DialogueManager.choices_ready.connect(_on_choices_ready)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):   # spacebar / A button
		get_viewport().set_input_as_handled()
		if _typing:
			# Skip typewriter
			_finish_typewriter()
		elif _waiting_for_advance:
			DialogueManager.advance()

func _process(delta: float) -> void:
	if not _typing:
		return
	_typewriter_timer += delta
	while _typewriter_timer >= _typewriter_speed and _visible_chars < _full_text.length():
		_visible_chars += 1
		_typewriter_timer -= _typewriter_speed
		line_label.visible_characters = _visible_chars
	if _visible_chars >= _full_text.length():
		_finish_typewriter()

func _on_line_ready(speaker: String, line: String) -> void:
	show()
	choices_container.visible = false
	for child: Node in choices_container.get_children():
		child.queue_free()

	speaker_label.text = speaker.to_upper()
	_start_typewriter(line)

func _on_choices_ready(choices: Array) -> void:
	await get_tree().create_timer(0.05).timeout
	while _typing:
		await get_tree().process_frame
	_show_choices(choices)

func _on_dialogue_ended() -> void:
	hide()

func _start_typewriter(text: String) -> void:
	_full_text = text
	_visible_chars = 0
	_typewriter_timer = 0.0
	_typing = true
	_waiting_for_advance = false
	line_label.text = text
	line_label.visible_characters = 0

func _finish_typewriter() -> void:
	_typing = false
	line_label.visible_characters = -1
	_waiting_for_advance = true

func _show_choices(choices: Array) -> void:
	_waiting_for_advance = false
	choices_container.visible = true
	for i: int in choices.size():
		var choice: Dictionary = choices[i]
		var btn: Button = Button.new()
		btn.text = choice.get("text", "...")
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_ALL
		var idx: int = i
		btn.pressed.connect(func() -> void: _on_choice_pressed(idx))
		choices_container.add_child(btn)
	if choices_container.get_child_count() > 0:
		(choices_container.get_child(0) as Button).grab_focus()

func _on_choice_pressed(index: int) -> void:
	for child: Node in choices_container.get_children():
		child.queue_free()
	choices_container.visible = false
	DialogueManager.select_choice(index)
