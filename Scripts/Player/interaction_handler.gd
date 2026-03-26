extends Area2D
# Handles player interactions with interactable objects in the world.
#
# Responsibilities:
#   - Detect when the player enters or exits an interactable's trigger area.
#   - Display a contextual prompt (e.g. "Press E to interact") near the object.
#   - Fire the interaction when the player presses the interact input action.
#   - Hide the prompt when the player moves away.
#
# Usage:
#   Add as a child of the player CharacterBody2D node.
#   Interactable objects in the scene should belong to an "interactable" group
#   and expose an interact() method that this script can call.
#
# Dependencies to set up:
#   - An input action named "player_interact" in the Input Map.
#   - Interactable scene nodes added to the "interactable" group.
#   - A UI prompt node (Label or custom Control) for the interaction hint.

## Path to the Label (or Control) used as the interaction prompt.
@export var prompt_node_path: NodePath = NodePath("")
## Text shown on the prompt. Override per-interactable if desired.
@export var default_prompt_text: String = "Press E to interact"

var _current_interactable: Node = null
var _prompt: Control = null

func _ready() -> void:
	# Connect area signals to detect interactables entering/leaving range
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Resolve the prompt node if a path was provided
	if prompt_node_path != NodePath(""):
		_prompt = get_node(prompt_node_path) as Control
	_hide_prompt()

func _unhandled_input(event: InputEvent) -> void:
	# Block interaction while dialogue is open
	if DialogueManager.is_open:
		return
	if event.is_action_pressed("player_interact"):
		_try_interact()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("interactable"):
		return
	# If multiple interactables overlap, keep the closest one
	if _current_interactable == null or _closer(body):
		_current_interactable = body
		_show_prompt(_get_prompt_text(body))

func _on_body_exited(body: Node2D) -> void:
	if body != _current_interactable:
		return
	_current_interactable = null
	_hide_prompt()
	# Check if another interactable is still in range
	_refresh_nearest()

func _try_interact() -> void:
	if _current_interactable == null:
		return
	if not _current_interactable.has_method("interact"):
		push_warning("[InteractionHandler] %s is in 'interactable' group but has no interact() method." % _current_interactable.name)
		return
	_current_interactable.call("interact")

func _show_prompt(text: String) -> void:
	if _prompt == null:
		return
	# If the prompt is a Label, set its text directly
	if _prompt is Label:
		(_prompt as Label).text = text
	# Position the prompt above the interactable in world space, then convert to the prompt's parent local space
	if _current_interactable != null:
		var world_pos: Vector2 = (_current_interactable as Node2D).global_position + Vector2(0.0, -40.0)
		_prompt.global_position = world_pos
	_prompt.show()

func _hide_prompt() -> void:
	if _prompt == null:
		return
	_prompt.hide()

func _get_prompt_text(interactable: Node) -> String:
	# Interactables can optionally expose a prompt_text property to override the default
	if interactable.get("prompt_text") != null:
		return str(interactable.get("prompt_text"))
	return default_prompt_text

func _refresh_nearest() -> void:
	# After the current interactable leaves, scan overlapping bodies in case another interactable is still within range.
	var best: Node = null
	var best_dist: float = INF
	for body: Node2D in get_overlapping_bodies():
		if not body.is_in_group("interactable"):
			continue
		var dist: float = global_position.distance_to(body.global_position)
		if dist < best_dist:
			best_dist = dist
			best = body
	if best != null:
		_current_interactable = best
		_show_prompt(_get_prompt_text(best))

func _closer(candidate: Node2D) -> bool:
	if _current_interactable == null:
		return true
	var current_node: Node2D = _current_interactable as Node2D
	return global_position.distance_to(candidate.global_position) \
		 < global_position.distance_to(current_node.global_position)
