extends Area2D

# Place on the FixControl Area2D node in the scene.
# When the player walks over it:
#   - Controls are restored to normal.
#   - Door_02 is removed from the scene.
#
# Setup:
#   - Set door_02 to the NodePath of the Door_02 node.

@export var door_02: NodePath = NodePath("")

var _used: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _used:
		return
	_used = true
	_fix_controls(body)
	_remove_door()
	GameState.set_flag("lava_puzzle_solved", true)

func _fix_controls(player: Node2D) -> void:
	for child: Node in player.get_children():
		if child is MovementHandler:
			(child as MovementHandler).controls_reversed = false
			return

func _remove_door() -> void:
	if door_02 == NodePath(""):
		return
	var door: Node = get_node_or_null(door_02)
	if door != null:
		door.queue_free()
