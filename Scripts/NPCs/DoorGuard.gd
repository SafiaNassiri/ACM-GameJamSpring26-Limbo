extends Area2D

## How long (seconds) to wait before firing the next ambient line.
@export var ambient_interval: float = 8.0
## Prompt shown when player is in range.
var prompt_text: String = "Talk to Mr. Greene"

const AMBIENT_EVERY_N_FAILS: int = 3

var _player_in_range: bool = false
var _ambient_pending: bool = false
var _ambient_lines: Array[String] = []

func _ready() -> void:
	_load_dialogue_json()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# If the player starts inside the area, body_entered never fires — check manually.
	await get_tree().physics_frame
	for body: Node2D in get_overlapping_bodies():
		_on_body_entered(body)

func _load_dialogue_json() -> void:
	var file: FileAccess = FileAccess.open("res://Data/Dialogue/door_guard.json", FileAccess.READ)
	if file == null:
		push_warning("[DoorGuard] Could not open dialogue JSON")
		return
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("[DoorGuard] Failed to parse dialogue JSON: " + json.get_error_message())
		return
	var raw: Variant = json.data
	if not raw is Dictionary:
		return
	@warning_ignore("unsafe_method_access")
	var lines: Variant = raw.get("ambient_lines")
	if lines is Array:
		@warning_ignore("unsafe_method_access")
		for item: Variant in lines:
			_ambient_lines.append(str(item))
	@warning_ignore("unsafe_method_access")
	var nodes: Variant = raw.get("nodes")
	if nodes is Dictionary:
		DialogueManager.register_script("door_guards", {"nodes": nodes})

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	if GameState.get_flag("lava_puzzle_solved"):
		DialogueManager.start_conversation("door_guards", "greene_revealed")
	elif GameState.has_seen("proximity_first"):
		DialogueManager.start_conversation("door_guards", "proximity_repeat")
	else:
		DialogueManager.start_conversation("door_guards", "proximity_first")

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	_ambient_pending = false

func _on_dialogue_ended() -> void:
	if _player_in_range:
		_schedule_ambient()

## Schedules the next ambient line after ambient_interval seconds.
## Only one schedule runs at a time; extra calls while one is pending are ignored.
func _schedule_ambient() -> void:
	if _ambient_pending:
		return
	_ambient_pending = true
	await get_tree().create_timer(ambient_interval).timeout
	if not _ambient_pending or not _player_in_range or DialogueManager.is_open:
		_ambient_pending = false
		return
	_ambient_pending = false
	_fire_ambient()

func interact() -> void:
	on_player_talk()

func on_player_died() -> void:
	GameState.increment("deaths")
	if GameState.get_flag("lava_puzzle_solved"):
		DialogueManager.start_conversation("door_guards", "greene_revealed")
		return
	var deaths: int = GameState.get_count("deaths")
	if deaths == 1:
		DialogueManager.start_conversation("door_guards", "death_first")
	elif deaths == 50:
		DialogueManager.start_conversation("door_guards", "death_milestone_50")
	elif deaths == 25:
		DialogueManager.start_conversation("door_guards", "death_milestone_25")
	elif deaths == 10:
		DialogueManager.start_conversation("door_guards", "death_milestone_10")
	else:
		DialogueManager.start_conversation("door_guards", "death_repeat", {"death_count": str(deaths)})

func on_player_failed_attempt() -> void:
	GameState.increment("fails")
	if GameState.get_flag("lava_puzzle_solved"):
		DialogueManager.start_conversation("door_guards", "greene_revealed")
		return
	var fails: int = GameState.get_count("fails")
	if fails % AMBIENT_EVERY_N_FAILS == 0:
		var pool: Array[String] = ["ambient_struggle", "ambient_struggle_grim"]
		var pick: String = pool[randi() % pool.size()]
		DialogueManager.start_conversation("door_guards", pick)

func on_player_talk() -> void:
	if GameState.get_flag("lava_puzzle_solved"):
		DialogueManager.start_conversation("door_guards", "greene_revealed")
		return
	DialogueManager.start_conversation("door_guards", "player_talks")

func on_player_wins() -> void:
	DialogueManager.start_conversation("door_guards", "player_wins")

func _fire_ambient() -> void:
	if GameState.get_flag("lava_puzzle_solved"):
		DialogueManager.start_conversation("door_guards", "greene_revealed")
		return
	if _ambient_lines.is_empty():
		return
	var line: String = _ambient_lines[randi() % _ambient_lines.size()]
	DialogueManager.start_conversation("door_guards", "ambient_idle", {"ambient_line": line})
