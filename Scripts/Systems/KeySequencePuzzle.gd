extends Node

# Listens for KeyTile step events and tracks the sequence 1 -> 2 -> 3 -> 4 -> 1.
# When completed, Door_03 is removed from the scene.
# Wrong step resets progress; stepping on the first key restarts the sequence.
#
# Setup:
#   - Set door_03 to the NodePath of the Door_03 TileMapLayer (or any Node).
#   - Place KeyTile Area2Ds in the scene with key_number set to 1-4.

const SEQUENCE: Array[int] = [1, 2, 3, 4, 1]

@export var door_03: NodePath = NodePath("")

var _progress: int = 0
var _solved: bool = false

func _ready() -> void:
	# Defer so all KeyTile _ready() calls have run and added themselves to the group.
	call_deferred("_connect_key_tiles")

func _connect_key_tiles() -> void:
	for tile: Node in get_tree().get_nodes_in_group("key_tile"):
		if tile.has_signal("stepped_on"):
			tile.connect("stepped_on", _on_key_stepped)

func _on_key_stepped(key_num: int) -> void:
	if _solved:
		return

	if key_num == SEQUENCE[_progress]:
		_progress += 1
		if _progress >= SEQUENCE.size():
			_solve()
	else:
		# Wrong key - reset, but count it as the first step if it matches.
		_progress = 0
		if key_num == SEQUENCE[0]:
			_progress = 1

func _solve() -> void:
	_solved = true
	if door_03 == NodePath(""):
		return
	var door: Node = get_node_or_null(door_03)
	if door != null:
		door.queue_free()
