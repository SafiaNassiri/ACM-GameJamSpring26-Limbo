extends Area2D

# Placed at the far-right end of Room 4.
# Teleports the player to the Room 5 spawn when they enter.

const ROOM5_SPAWN: Vector2 = Vector2(350.0, 264.0) 

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    body.global_position = ROOM5_SPAWN
