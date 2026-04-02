extends Node

const SEQUENCE: Array[int] = [1, 2, 3, 4, 1]

@export var door_03: NodePath = NodePath("")
@export var exit_area: NodePath = NodePath("")
@export var game_over_scene: String = "res://Scenes/UI/GameOver.tscn"

var _progress: int = 0
var _solved: bool = false

func _ready() -> void:
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
		_progress = 0
		if key_num == SEQUENCE[0]:
			_progress = 1

func _solve() -> void:
	_solved = true

	# Remove Door_03 TileMapLayer (visual + collision gone instantly)
	var door: Node = get_node_or_null(door_03)
	if door != null and door.is_inside_tree():
		door.queue_free()

	# Activate exit Area2D now that the door is gone
	var area: Area2D = get_node_or_null(exit_area) as Area2D
	if area != null:
		area.body_entered.connect(_on_exit_entered)

func _on_exit_entered(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(game_over_scene)
