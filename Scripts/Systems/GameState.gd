extends Node

var _flags: Dictionary = {}       # { "flag_name": bool }
var _counters: Dictionary = {}    # { "counter_name": int }
var _seen_lines: Dictionary = {}  # { "line_id": true }
var _str_flags: Dictionary = {}   # { "key": "string value" } e.g. player name

func set_flag(name: String, value: bool = true) -> void:
	_flags[name] = value

func get_flag(name: String) -> bool:
	return _flags.get(name, false)

func get_flag_str(name: String, default: String = "") -> String:
	return _str_flags.get(name, default)

func set_flag_str(name: String, value: String) -> void:
	_str_flags[name] = value

func increment(name: String, amount: int = 1) -> void:
	_counters[name] = get_count(name) + amount

func get_count(name: String) -> int:
	return _counters.get(name, 0)

func reset_count(name: String) -> void:
	_counters[name] = 0

func mark_seen(id: String) -> void:
	_seen_lines[id] = true

func has_seen(id: String) -> bool:
	return _seen_lines.get(id, false)

func reset_all() -> void:
	_flags.clear()
	_counters.clear()
	_seen_lines.clear()
	_str_flags.clear()
