extends Node

signal dialogue_started
signal line_ready(speaker: String, line: String, portrait: String)
signal choices_ready(choices: Array)
signal dialogue_ended
signal dialogue_trigger(trigger: Dictionary)  # {type, sound, animation, ...}

var _scripts: Dictionary = {}       # registered script resources
var _active_script: Dictionary = {}
var _active_node_id: String = ""
var _context: Dictionary = {}       # extra data passed in (e.g. death_count)
var is_open: bool = false

func register_script(name: String, script_data: Dictionary) -> void:
	_scripts[name] = script_data

func start_conversation(script_name: String, node_id: String = "start", context: Dictionary = {}) -> void:
	if not _scripts.has(script_name):
		push_warning("[DialogueManager] No script registered: %s" % script_name)
		return

	_active_script = _scripts[script_name]
	_active_node_id = node_id
	_context = context
	is_open = true
	emit_signal("dialogue_started")
	_play_node(node_id)

func advance() -> void:
	if not is_open or _active_node_id == "":
		return
	var node: Dictionary = _get_node(_active_node_id)
	if node.is_empty():
		return
	if node.has("choices"):
		return
	if node.has("effect"):
		_run_effect(node["effect"])
	var next: String = node.get("next", "END")
	_go_to(next)

func select_choice(index: int) -> void:
	if not is_open:
		return
	var node: Dictionary = _get_node(_active_node_id)
	if node.is_empty() or not node.has("choices"):
		return
	var choices: Array = node["choices"]
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	if choice.has("effect"):
		_run_effect(choice["effect"])
	_go_to(choice.get("next", "END"))

func _go_to(node_id: String) -> void:
	if node_id == "END":
		_end_conversation()
		return
	_active_node_id = node_id
	_play_node(node_id)

func _play_node(node_id: String) -> void:
	var node: Dictionary = _get_node(node_id)
	if node.is_empty():
		push_warning("[DialogueManager] Missing node: %s" % node_id)
		_end_conversation()
		return

	# Evaluate condition
	if node.has("condition"):
		if not _eval_condition(node["condition"]):
			_go_to(node.get("else", "END"))
			return

	# Mark seen
	if node.has("id"):
		GameState.mark_seen(node["id"])

	# Pick line
	var line: String = ""
	if node.has("line"):
		var raw: Variant = node["line"]
		if raw is Array:
			line = _pick_line(raw, node.get("id", ""))
		else:
			line = str(raw)
		line = _interpolate(line)

	var speaker: String = node.get("speaker", "")
	var portrait: String = node.get("portrait", "")

	emit_signal("line_ready", speaker, line, portrait)

	if node.has("choices"):
		emit_signal("choices_ready", node["choices"])

	# Fire trigger (sound, animation, etc.)
	if node.has("trigger"):
		emit_signal("dialogue_trigger", node["trigger"])

	# Auto-advance
	if node.get("auto_advance", false):
		var delay: float = node.get("delay", 0.0)
		await get_tree().create_timer(delay).timeout
		advance()

func _pick_line(lines: Array, node_id: String) -> String:
	var unseen: Array = lines.filter(func(l: String) -> bool: return not GameState.has_seen("%s_%s" % [node_id, l]))
	var pool: Array = unseen if unseen.size() > 0 else lines
	var pick: String = pool[randi() % pool.size()]
	if node_id != "":
		GameState.mark_seen("%s_%s" % [node_id, pick])
	return pick

func _interpolate(text: String) -> String:
	var vars: Dictionary = {
		"death_count": str(GameState.get_count("deaths")),
		"fail_count":  str(GameState.get_count("fails")),
		"player_name": GameState.get_flag_str("player_name", "you"),
	}
	vars.merge(_context)
	var result: String = text
	for key: String in vars:
		result = result.replace("{%s}" % key, str(vars[key]))
	return result

func _eval_condition(cond: Dictionary) -> bool:
	if cond.has("flag"):
		var expected: bool = cond.get("value", true)
		return GameState.get_flag(cond["flag"]) == expected
	if cond.has("counter"):
		var val: int = GameState.get_count(cond["counter"])
		if cond.has("gte"): return val >= int(cond["gte"])
		if cond.has("lte"): return val <= int(cond["lte"])
		if cond.has("eq"):  return val == int(cond["eq"])
	return true

func _run_effect(effect: Dictionary) -> void:
	if effect.has("set_flag"):
		GameState.set_flag(effect["set_flag"], effect.get("value", true))
	if effect.has("increment"):
		GameState.increment(effect["increment"], effect.get("by", 1))

func _get_node(node_id: String) -> Dictionary:
	if _active_script.has("nodes"):
		var nodes: Dictionary = _active_script["nodes"]
		if nodes.has(node_id):
			return nodes[node_id]
	return {}

func _end_conversation() -> void:
	is_open = false
	_active_node_id = ""
	_active_script = {}
	emit_signal("dialogue_ended")
