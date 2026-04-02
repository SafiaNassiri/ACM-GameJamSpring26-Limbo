extends Area2D

# Place on each floor-tile Area2D that is part of the key-sequence puzzle.
# Set key_number in the inspector to 1, 2, 3, or 4.
# The node is automatically added to the "key_tile" group so
# KeySequencePuzzle can find it.

signal stepped_on(key_num: int)

@export var key_number: int = 1

func _ready() -> void:
    add_to_group("key_tile")
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    stepped_on.emit(key_number)
