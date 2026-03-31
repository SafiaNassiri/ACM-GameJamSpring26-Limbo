extends StaticBody2D

# Interactable button in Room 5.
# First interaction: plays intro dialogue, then teleports player to a random room.
# Subsequent interactions: teleports immediately.
# After 3 uses the 4th use always sends the player to Room 6 (no door, no exit).

const FORCED_ROOM6_AFTER: int = 3
const USES_COUNTER: String = "teleport_button_uses"
const INTRO_SEEN_FLAG: String = "teleport_button_intro"

const BUTTON_DIALOGUE: Dictionary = {
    "nodes": {
        "start": {
            "speaker": "BUTTON",
            "line": "Pressing this button will take you to a random room.",
            "next": "warn",
        },
        "warn": {
            "speaker": "BUTTON",
            "line": "I'm the only way you will be able to get to the next room... If you're lucky.",
            "next": "note",
        },
        "note": {
            "speaker": "BUTTON",
            "line": "Good Luck... You'll need it.",
            "next": "END",
        },
    }
}

# World-space spawn positions for rooms 1–6.
var _room_spawns: Array[Vector2] = [
    Vector2(160.0,  88.0),   # Room 1 — starting room
    Vector2(160.0, 264.0),   # Room 2 — tutorial
    Vector2(160.0, 361.0),   # Room 3 — progress-bar puzzle
    Vector2(350.0, 361.0),   # Room 4 — chasing-wall run
    Vector2(350.0, 264.0),  # Room 5 — just past the Room 4 exit
    Vector2(350.0, 88.0),  # Room 6 — isolated, no door
]

## Text shown by the player's interaction prompt.
var prompt_text: String = "Press E to use button"

func _ready() -> void:
    DialogueManager.register_script("teleport_button", BUTTON_DIALOGUE)

func interact() -> void:
    if not GameState.has_seen(INTRO_SEEN_FLAG):
        DialogueManager.start_conversation("teleport_button")
        await DialogueManager.dialogue_ended
        GameState.mark_seen(INTRO_SEEN_FLAG)
    _do_teleport()

func _do_teleport() -> void:
    var players: Array[Node] = get_tree().get_nodes_in_group("player")
    if players.is_empty():
        return
    @warning_ignore("unsafe_cast")
    var player: Node2D = players[0] as Node2D
    if player == null:
        return

    GameState.increment(USES_COUNTER)
    var uses: int = GameState.get_count(USES_COUNTER)

    var target: Vector2
    if uses > FORCED_ROOM6_AFTER:
        target = _room_spawns[5]  # force Room 6
    else:
        var idx: int = randi() % _room_spawns.size()
        target = _room_spawns[idx]

    player.global_position = target
