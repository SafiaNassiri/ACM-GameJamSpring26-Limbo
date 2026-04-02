extends Area2D

# Place this script on any Area2D that belongs to the "lava" group.
# When the player enters, they are teleported to the respawn point and
# any reversed-controls effect is cleared.

const RESPAWN: Vector2 = Vector2(344.0, 72.0)

func _ready() -> void:
    add_to_group("lava")
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    body.global_position = RESPAWN
    _clear_reversed_controls(body)

func _clear_reversed_controls(player: Node2D) -> void:
    for child: Node in player.get_children():
        if child is MovementHandler:
            (child as MovementHandler).controls_reversed = false
            return
