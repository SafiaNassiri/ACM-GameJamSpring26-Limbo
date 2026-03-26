extends Node2D

const SNAP_DISTANCE: float = 6.0
const MIN_MOVE_DISTANCE: float = 60.0
const MOVE_DURATION: float = 0.5
const COMPLETION_REQUIRED: int = 5

# Walkable room bounds in world space — adjust to match your room layout.
const ROOM_MIN: Vector2 = Vector2(20.0, 20.0)
const ROOM_MAX: Vector2 = Vector2(300.0, 156.0)

var _completions: int = 0
var _active: bool = true
var _busy: bool = false

@onready var _audio: AudioStreamPlayer = $AudioStreamPlayer

var _rock: Node2D = null
var _player: Node = null
var _door: TileMapLayer = null

func _ready() -> void:
	_rock = get_parent().get_node("Rock") as Node2D
	_player = get_parent().get_node("Player")
	_door = get_parent().get_node("TitleLayers/Door_01") as TileMapLayer

func _physics_process(_delta: float) -> void:
	if not _active or _busy or _rock == null:
		return
	if _rock.global_position.distance_to(global_position) <= SNAP_DISTANCE:
		_on_rock_placed()

func _on_rock_placed() -> void:
	_busy = true
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	_audio.play()
	_completions += 1

	if _completions >= COMPLETION_REQUIRED:
		_complete_puzzle()
		return

	await _animate_to_new_position()
	_player.process_mode = Node.PROCESS_MODE_INHERIT
	_busy = false

func _animate_to_new_position() -> void:
	var new_pos: Vector2 = _pick_random_position()
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", new_pos, MOVE_DURATION)
	await tween.finished

func _pick_random_position() -> Vector2:
	var current: Vector2 = global_position
	for _i: int in range(100):
		var candidate: Vector2 = Vector2(
			randf_range(ROOM_MIN.x, ROOM_MAX.x),
			randf_range(ROOM_MIN.y, ROOM_MAX.y)
		)
		if candidate.distance_to(current) >= MIN_MOVE_DISTANCE:
			return candidate
	# Fallback: go to the far end of the room from the current position.
	var mid_x: float = (ROOM_MIN.x + ROOM_MAX.x) * 0.5
	if current.x <= mid_x:
		return Vector2(ROOM_MAX.x - 24.0, randf_range(ROOM_MIN.y, ROOM_MAX.y))
	return Vector2(ROOM_MIN.x + 24.0, randf_range(ROOM_MIN.y, ROOM_MAX.y))

func _complete_puzzle() -> void:
	_active = false
	visible = false
	if _door != null:
		_door.visible = false
		_door.collision_enabled = false
	_player.process_mode = Node.PROCESS_MODE_INHERIT
