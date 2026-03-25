extends Camera2D

const ROOM_WIDTH: int = 320
const ROOM_HEIGHT: int = 176

@export var player_path: NodePath = NodePath("../Player")

var _player: Node2D
var _current_room: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	_player = get_node(player_path) as Node2D
	if _player != null:
		_snap_to_room(_get_room(_player.position))

func _physics_process(_delta: float) -> void:
	if _player == null:
		return
	var room: Vector2i = _get_room(_player.position)
	if room != _current_room:
		_snap_to_room(room)

func _get_room(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_pos.x / ROOM_WIDTH),
		floori(world_pos.y / ROOM_HEIGHT)
	)

func _snap_to_room(room: Vector2i) -> void:
	_current_room = room
	position = Vector2(
		room.x * ROOM_WIDTH + ROOM_WIDTH / 2.0,
		room.y * ROOM_HEIGHT + ROOM_HEIGHT / 2.0
	)
