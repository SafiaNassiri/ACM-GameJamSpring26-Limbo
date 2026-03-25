extends Node

# Top-down 8-directional movement handler.
# Animations use directional suffixes: _down, _up, _right.
# Left movement mirrors the _right animations via sprite.flip_h.

@export var speed: float = 90.0

@onready var body: CharacterBody2D = get_parent() as CharacterBody2D
@onready var sprite: AnimatedSprite2D = body.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

enum State { IDLE, RUN }

# Tracks the last movement direction for idle animation selection.
enum Direction { DOWN, UP, RIGHT, LEFT }

var state: State = State.IDLE
var facing: Direction = Direction.DOWN

func _physics_process(delta: float) -> void:
    if body == null:
        return

    var input_dir: Vector2 = Input.get_vector(
        "player_left", "player_right", "player_up", "player_down"
    )

    if input_dir != Vector2.ZERO:
        body.velocity = input_dir.normalized() * speed
        _update_facing(input_dir)
        state = State.RUN
    else:
        body.velocity = Vector2.ZERO
        state = State.IDLE

    body.move_and_slide()
    _apply_animation()

func _update_facing(dir: Vector2) -> void:
    # Prefer horizontal facing when moving diagonally.
    if abs(dir.x) >= abs(dir.y):
        facing = Direction.RIGHT if dir.x > 0.0 else Direction.LEFT
    else:
        facing = Direction.DOWN if dir.y > 0.0 else Direction.UP

func _apply_animation() -> void:
    if sprite == null:
        return

    match state:
        State.IDLE:
            _play_directional("idle")
        State.RUN:
            _play_directional("run")

func _play_directional(prefix: String) -> void:
    var anim_name: String
    sprite.flip_h = false

    match facing:
        Direction.DOWN:
            anim_name = prefix + "_down"
        Direction.UP:
            anim_name = prefix + "_up"
        Direction.RIGHT:
            anim_name = prefix + "_right"
        Direction.LEFT:
            anim_name = prefix + "_right"
            sprite.flip_h = true
        _:
            anim_name = prefix + "_down"

    if sprite.animation != anim_name or not sprite.is_playing():
        sprite.play(anim_name)
