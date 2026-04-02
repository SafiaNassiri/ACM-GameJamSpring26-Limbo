extends Area2D

# Place on the RevControl Area2D node in the scene.
# When the player walks over it, their movement controls are inverted
# until they touch lava (which resets them).

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	for child: Node in body.get_children():
		if child is MovementHandler:
			(child as MovementHandler).controls_reversed = true
			return
