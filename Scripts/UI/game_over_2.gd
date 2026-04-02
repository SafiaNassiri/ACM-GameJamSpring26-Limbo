extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_rich_text_label_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
	#Space - ui_accept

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/GameOver3.tscn")
