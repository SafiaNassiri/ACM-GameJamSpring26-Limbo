# Node setup:
#   DoorGuardArea (Area2D or Area3D)
#   ├── CollisionShape2D   ← proximity detection zone
#   └── DoorGuard.gd       ← this script

extends Node

# How many failed attempts before ambient taunts trigger
const AMBIENT_EVERY_N_FAILS: int = 3

func _ready() -> void:
	DialogueManager.register_script("door_guards", _build_script())
	DialogueManager.dialogue_trigger.connect(_on_dialogue_trigger)

func on_player_enter_proximity() -> void:
	if GameState.has_seen("proximity_first"):
		DialogueManager.start_conversation("door_guards", "proximity_repeat")
	else:
		DialogueManager.start_conversation("door_guards", "proximity_first")

func on_player_died() -> void:
	GameState.increment("deaths")
	var deaths: int = GameState.get_count("deaths")

	if deaths == 1:
		DialogueManager.start_conversation("door_guards", "death_first")
	elif deaths == 50:
		DialogueManager.start_conversation("door_guards", "death_milestone_50")
	elif deaths == 25:
		DialogueManager.start_conversation("door_guards", "death_milestone_25")
	elif deaths == 10:
		DialogueManager.start_conversation("door_guards", "death_milestone_10")
	else:
		DialogueManager.start_conversation("door_guards", "death_repeat", {"death_count": str(deaths)})

func on_player_failed_attempt() -> void:
	GameState.increment("fails")
	var fails: int = GameState.get_count("fails")
	if fails % AMBIENT_EVERY_N_FAILS == 0:
		var pool: Array[String] = ["ambient_struggle", "ambient_struggle_grim"]
		var pick: String = pool[randi() % pool.size()]
		DialogueManager.start_conversation("door_guards", pick)

func on_player_talk() -> void:
	DialogueManager.start_conversation("door_guards", "player_talks")

func on_player_wins() -> void:
	DialogueManager.start_conversation("door_guards", "player_wins")

func _on_dialogue_trigger(trigger: Dictionary) -> void:
	match trigger.get("type", ""):
		"ambient":
			# AudioManager.play(trigger.get("sound", ""))
			pass
		"emote":
			# $AnimationPlayer.play(trigger.get("animation", ""))
			pass

func _build_script() -> Dictionary:
	return {
		"nodes": {

			#  PROXIMITY 
			"proximity_first": {
				"id": "proximity_first",
				"speaker": "Grim",
				"line": "Oh. Another one.",
				"next": "proximity_first_b",
			},
			"proximity_first_b": {
				"id": "proximity_first_b",
				"speaker": "Snort",
				"line": "Heheheh. Yeah they always look SO confident walking up.",
				"next": "proximity_first_c",
			},
			"proximity_first_c": {
				"id": "proximity_first_c",
				"speaker": "Grim",
				"line": "Take your time. The door isn't going anywhere. Unfortunately, neither are you.",
				"next": "END",
			},

			"proximity_repeat": {
				"id": "proximity_repeat",
				"speaker": "Snort",
				"line": [
					"Back again! I love this part of the job.",
					"Oh don't worry, we didn't forget you.",
					"Pfft — yep, still here. Still you.",
					"I keep a tally. Wanna know the number?",
					"I told Grim you'd be back. He owes me lunch.",
				],
				"next": "END",
			},

			#  DEATH — FIRST 
			"death_first": {
				"id": "death_first",
				"speaker": "Snort",
				"line": "HAHAHA. Oh — oh that was — did you SEE that, Grim?",
				"next": "death_first_b",
			},
			"death_first_b": {
				"id": "death_first_b",
				"speaker": "Grim",
				"line": "I see everything. I have nothing else to do.",
				"next": "death_first_c",
			},
			"death_first_c": {
				"id": "death_first_c",
				"speaker": "Snort",
				"line": "Don't worry, that was just a warmup. Heh. Heheheh.",
				"next": "END",
			},

			#  DEATH — REPEAT 
			"death_repeat": {
				"id": "death_repeat",
				"speaker": "Snort",
				"line": [
					"Again! Heheh! You're getting WORSE.",
					"Ooooh, SO close. Not really, but we say that.",
					"I've been keeping count. You wanna know the number?",
					"At this rate we'll be here forever. Actually, we ARE here forever. This rules.",
					"That one looked painful. Emotionally, I mean. Physically too I suppose.",
				],
				"next": "death_repeat_grim",
			},
			"death_repeat_grim": {
				"id": "death_repeat_grim",
				"speaker": "Grim",
				"line": [
					"Death count: {death_count}. Just so you have a number to reflect on.",
					"Curious. You keep doing the same thing expecting different results.",
					"Each attempt is technically progress. You're learning what doesn't work.",
					"I have started to feel something watching you. I believe it is pity.",
					"Do you have a plan, or is this purely improvisational?",
				],
				"next": "END",
			},

			#  MILESTONES 
			"death_milestone_10": {
				"id": "death_milestone_10",
				"condition": {"counter": "deaths", "gte": 10},
				"speaker": "Snort",
				"line": "TEN TIMES. We hit TEN. I made a little cake. In my head. For this moment.",
				"next": "death_milestone_10_b",
				"else": "END",
			},
			"death_milestone_10_b": {
				"id": "death_milestone_10_b",
				"speaker": "Grim",
				"line": "I considered saying something encouraging. I decided against it.",
				"next": "END",
			},

			"death_milestone_25": {
				"id": "death_milestone_25",
				"condition": {"counter": "deaths", "gte": 25},
				"speaker": "Grim",
				"line": "Twenty-five. I want you to know I have started to respect this. Slightly. Don't let it go to your head.",
				"next": "death_milestone_25_b",
				"else": "END",
			},
			"death_milestone_25_b": {
				"id": "death_milestone_25_b",
				"speaker": "Snort",
				"line": "...okay yeah, twenty-five IS kind of impressive. Still funny though. HEHEH.",
				"next": "END",
			},

			"death_milestone_50": {
				"id": "death_milestone_50",
				"condition": {"counter": "deaths", "gte": 50},
				"speaker": "Grim",
				"line": "Fifty deaths. I have been standing here watching you for longer than some entire careers. I have no words.",
				"next": "death_milestone_50_b",
				"else": "END",
			},
			"death_milestone_50_b": {
				"id": "death_milestone_50_b",
				"speaker": "Snort",
				"line": "...I'm not even laughing anymore. I'm just — I'm in awe.",
				"next": "death_milestone_50_c",
			},
			"death_milestone_50_c": {
				"id": "death_milestone_50_c",
				"speaker": "Snort",
				"line": "Okay no I'm still laughing. HEHEHEH.",
				"next": "END",
			},

			#  PLAYER TALKS 
			"player_talks": {
				"id": "player_talks",
				"speaker": "Grim",
				"line": "You want help.",
				"next": "player_talks_b",
			},
			"player_talks_b": {
				"id": "player_talks_b",
				"speaker": "Snort",
				"line": "Pfff — they WANT HELP, Grim. They're asking US.",
				"next": "player_talks_choices",
			},
			"player_talks_choices": {
				"id": "player_talks_choices",
				"speaker": "Grim",
				"line": "We could offer... advice. Of a kind.",
				"choices": [
					{"text": "Yes, please. Any tips?",              "next": "hint_bad_a"},
					{"text": "What's behind the door?",             "next": "hint_door"},
					{"text": "Never mind, I don't need help.",       "next": "hint_refuse"},
				],
			},

			"hint_bad_a": {
				"id": "hint_bad_a",
				"speaker": "Grim",
				"line": "The key is commitment. Go faster. Much faster. Do not hesitate.",
				"next": "hint_bad_a_b",
			},
			"hint_bad_a_b": {
				"id": "hint_bad_a_b",
				"speaker": "Snort",
				"line": "Yep. Speed. That's definitely the thing. Go with speed.",
				"next": "hint_bad_a_c",
			},
			"hint_bad_a_c": {
				"id": "hint_bad_a_c",
				"speaker": "Grim",
				"line": "Trust us.",
				"trigger": {"type": "ambient", "sound": "dry_cough"},
				"next": "END",
			},

			"hint_door": {
				"id": "hint_door",
				"speaker": "Grim",
				"line": "Something wonderful.",
				"next": "hint_door_b",
			},
			"hint_door_b": {
				"id": "hint_door_b",
				"speaker": "Snort",
				"line": "...I mean, sure. 'Wonderful.' Let's say that.",
				"next": "hint_door_c",
			},
			"hint_door_c": {
				"id": "hint_door_c",
				"speaker": "Grim",
				"line": "You'll find out. Theoretically.",
				"next": "END",
			},

			"hint_refuse": {
				"id": "hint_refuse",
				"speaker": "Snort",
				"line": "Sure. Sure you don't.",
				"next": "hint_refuse_b",
			},
			"hint_refuse_b": {
				"id": "hint_refuse_b",
				"speaker": "Grim",
				"line": "Good luck.",
				"next": "hint_refuse_c",
			},
			"hint_refuse_c": {
				"id": "hint_refuse_c",
				"speaker": "Snort",
				"line": "Heheheh.",
				"next": "END",
			},

			#  AMBIENT STRUGGLE 
			"ambient_struggle": {
				"id": "ambient_struggle",
				"speaker": "Snort",
				"line": [
					"Oooh — no. No no. Aaand no.",
					"So close. Again. Heh.",
					"That gap was RIGHT THERE.",
					"I physically flinched. Grim did you flinch?",
					"Almost! That was almost it! Heheh, no it wasn't.",
					"One day. Maybe. Heheheh.",
				],
				"next": "END",
			},
			"ambient_struggle_grim": {
				"id": "ambient_struggle_grim",
				"speaker": "Grim",
				"line": [
					"I did not flinch.",
					"Watching this has given me a new appreciation for stillness.",
					"The obstacle does not change. Consider why you keep changing your approach.",
					"Hmm.",
					"Persistent.",
					"I have begun to wonder if you enjoy this.",
				],
				"next": "END",
			},

			#  PLAYER WINS 
			"player_wins": {
				"id": "player_wins",
				"speaker": "Snort",
				"line": "Wait — what? WHAT? They — Grim. GRIM.",
				"next": "player_wins_b",
			},
			"player_wins_b": {
				"id": "player_wins_b",
				"speaker": "Grim",
				"line": "...Hm.",
				"next": "player_wins_c",
			},
			"player_wins_c": {
				"id": "player_wins_c",
				"speaker": "Snort",
				"line": "That's IT? That's all you've got? They ACTUALLY DID IT and all you say is 'hm'??",
				"next": "player_wins_d",
			},
			"player_wins_d": {
				"id": "player_wins_d",
				"speaker": "Grim",
				"line": "I feel something I cannot name. I believe it is... respect. Go. Before it passes.",
				"trigger": {"type": "emote", "animation": "grim_nod"},
				"next": "END",
			},
		}
	}
