extends StaticBody2D

# Room 4 occupies cols 1–4, row 2 (each room is 320x176 px).
const ROOM_WIDTH: int = 320
const ROOM_HEIGHT: int = 176
const ROOM4_START_X: float = 320.0   # col 1 * ROOM_WIDTH
const ROOM4_END_X: float = 1600.0    # (col 1 + 4) * ROOM_WIDTH
const ROOM4_TOP_Y: float = 352.0     # row 2 * ROOM_HEIGHT
const ROOM4_BOT_Y: float = 528.0     # row 3 * ROOM_HEIGHT

# Wall starts following when player reaches the middle of the first sub-room.
const FOLLOW_START_X: float = ROOM4_START_X + ROOM_WIDTH / 2.0  # 480
# Wall stops following when player reaches the end minus half a room.
const FOLLOW_STOP_X: float = ROOM4_END_X - ROOM_WIDTH / 2.0     # 1440

@export var player_path: NodePath = NodePath("../Player")

var _player: Node2D
var _initial_position: Vector2
var _wall_offset: float = 0.0
var _in_room4: bool = false
var _wall_stopped: bool = false

func _ready() -> void:
	_player = get_node(player_path) as Node2D
	_initial_position = global_position
	# Offset keeps the wall at its starting x when the player first hits FOLLOW_START_X.
	_wall_offset = _initial_position.x - FOLLOW_START_X

func _physics_process(_delta: float) -> void:
	if _player == null:
		return

	var px: float = _player.global_position.x
	var py: float = _player.global_position.y

	var in_room4: bool = (
		px >= ROOM4_START_X and
		px < ROOM4_END_X and
		py >= ROOM4_TOP_Y and
		py < ROOM4_BOT_Y
	)

	if not in_room4:
		if _in_room4:
			global_position = _initial_position
			_in_room4 = false
			_wall_stopped = false
		return

	_in_room4 = true

	if _wall_stopped or px < FOLLOW_START_X:
		return

	if px >= FOLLOW_STOP_X:
		_wall_stopped = true
		return

	global_position.x = px + _wall_offset
