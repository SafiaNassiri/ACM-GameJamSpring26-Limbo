extends HSlider

func _ready() -> void:
	min_value = 0.0
	max_value = 1.0
	step = 0.01
	value = AudioManager.get_master_volume()
	value_changed.connect(_on_volume_changed)

func _on_volume_changed(val: float) -> void:
	AudioManager.set_master_volume(val)
