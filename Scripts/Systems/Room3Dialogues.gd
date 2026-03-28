const CHECKPOINT_REAL: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "", "line": "Checkpoint saved!",
			"auto_advance": true, "delay": 1.5, "next": "END"
		}
	}
}

const BUTTON_PRESS_1: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "", "line": "...",
			"auto_advance": true, "delay": 1.0, "next": "END"
		}
	}
}

const BUTTON_PRESS_2: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "", "line": "Hm.",
			"auto_advance": true, "delay": 1.0, "next": "END"
		}
	}
}

const PRESS_HINT_10: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "", "line": "Getting warmer...",
			"auto_advance": true, "delay": 1.5, "next": "END"
		}
	}
}

const PRESS_HINT_20: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "", "line": "Bold strategy. Keep going.",
			"auto_advance": true, "delay": 1.5, "next": "END"
		}
	}
}

const DOOR_REVEALED: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "", "line": "Oh look. A door.",
			"auto_advance": true, "delay": 2.0, "next": "END"
		}
	}
}

const FAKE_DOOR_TROLL: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "",
			"line": "Room 4 is currently under construction.",
			"auto_advance": true, "delay": 2.0, "next": "apologize"
		},
		"apologize": {
			"speaker": "",
			"line": "Please enjoy Room 3 again. :)",
			"auto_advance": true, "delay": 2.0, "next": "END"
		}
	}
}

const REAL_DOOR_HINT: Dictionary = {
	"nodes": {
		"start": {
			"speaker": "",
			"line": "The real door is around here somewhere. Probably.",
			"auto_advance": true, "delay": 2.5, "next": "END"
		}
	}
}
