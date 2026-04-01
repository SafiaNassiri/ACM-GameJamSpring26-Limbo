extends Node

## Autoload audio manager.
##
## play_music(stream)  — start a looping background track.
## play_sound(stream)  — fire-and-forget sound effect.
##
## Room 3 crossfade behaviour:
##   • call enter_room3_music(stream) when the player enters Room 3.
##   • call exit_room3_music()        when the player leaves Room 3.
##   • call set_bar_active(true/false) when the progress bar starts/stops.
##   • call notify_space_press()       each time the player presses SPACE.
##
## While the bar is active the background music and Room 3 music crossfade
## based on how fast the player is pressing SPACE.  Faster → Room 3 louder,
## background quieter.  Slower / stopped → reverses.  Background never
## stops; it just gets softer.

# ── SFX pool ──────────────────────────────────────────────────────────────────
const SFX_POOL_SIZE: int = 8
var _sfx_players: Array[AudioStreamPlayer] = []

# ── Normal music ──────────────────────────────────────────────────────────────
var _music_player: AudioStreamPlayer
var _current_music: AudioStream  # null when nothing is queued

# ── Room 3 music ──────────────────────────────────────────────────────────────
var _room3_player: AudioStreamPlayer
var _in_room3: bool    = false
var _bar_active: bool  = false

## How much the background fades (dB) at maximum press rate.
## Background stays audible but becomes secondary.
const BG_FADE_DB: float = -20.0

## Room 3 music volume when idle (no pressing).
const ROOM3_MIN_DB: float = -40.0
## Room 3 music volume at maximum press rate.
const ROOM3_MAX_DB: float = 0.0

## Maximum rate of volume change in dB/second.
const ROOM3_VOLUME_SLEW: float = 60.0

## Presses per second that maps to full Room 3 volume.
const ROOM3_MAX_RATE: float = 5.0
## Seconds with no press before the rate begins decaying.
const ROOM3_DECAY_DELAY: float = 0.4
## How fast the press rate decays (units per second).
const ROOM3_RATE_DECAY: float = 4.0

var _press_rate: float      = 0.0
var _last_press_time: float = -999.0


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)

	_room3_player = AudioStreamPlayer.new()
	add_child(_room3_player)

	for _i: int in range(SFX_POOL_SIZE):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(p)
		_sfx_players.append(p)


# ── Public API ────────────────────────────────────────────────────────────────

## Start (or switch to) a looping music track.
## Safe to call while in Room 3 — the track will play/continue at the
## volume determined by the current crossfade state.
func play_music(music: AudioStream) -> void:
	_current_music = music
	if music == null:
		_music_player.stop()
		return
	if _music_player.stream != music:
		_music_player.stream = music
		_music_player.play()
	elif not _music_player.playing:
		_music_player.play()


## Play a non-looping sound effect.  Steals the oldest slot when the pool is full.
func play_sound(sound: AudioStream) -> void:
	for player: AudioStreamPlayer in _sfx_players:
		if not player.playing:
			player.stream = sound
			player.play()
			return
	_sfx_players[0].stream = sound
	_sfx_players[0].play()


## Call when the player enters Room 3.
## Starts the Room 3 track at minimum volume while the background keeps playing.
func enter_room3_music(room3_music: AudioStream) -> void:
	if _in_room3:
		return
	_in_room3 = true
	_press_rate = 0.0
	_last_press_time = -999.0

	_room3_player.stream = room3_music
	_room3_player.volume_db = ROOM3_MIN_DB
	if room3_music != null:
		_room3_player.play()


## Call when the player leaves Room 3.
## Stops the Room 3 track and snaps both volumes back to normal.
func exit_room3_music() -> void:
	if not _in_room3:
		return
	_in_room3   = false
	_bar_active = false
	_press_rate = 0.0
	_room3_player.stop()
	_music_player.volume_db = 0.0


## Call when the progress bar becomes active (start_bar) or inactive (hide_bar / done).
func set_bar_active(active: bool) -> void:
	_bar_active = active
	if not active:
		_press_rate = 0.0


## Call each time the player presses SPACE during Room 3.
func notify_space_press() -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	var dt: float  = now - _last_press_time
	if dt > 0.0 and dt < 2.0:
		var instant_rate: float = 1.0 / dt
		var capped: float = min(instant_rate, ROOM3_MAX_RATE * 2.0)
		_press_rate = lerp(_press_rate, capped, 0.6)
	_last_press_time = now


# ── Per-frame update ──────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _in_room3:
		return

	# Decay press rate after a pause in pressing.
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _last_press_time > ROOM3_DECAY_DELAY:
		_press_rate = move_toward(_press_rate, 0.0, ROOM3_RATE_DECAY * delta)

	# Compute target volumes.
	var room3_target: float
	var bg_target: float

	if _bar_active:
		# Crossfade based on press rate.
		var t: float = clamp(_press_rate / ROOM3_MAX_RATE, 0.0, 1.0)
		room3_target = lerp(ROOM3_MIN_DB, ROOM3_MAX_DB, t)
		bg_target    = lerp(0.0, BG_FADE_DB, t)
	else:
		# Bar not running — Room 3 track stays silent, background at full.
		room3_target = ROOM3_MIN_DB
		bg_target    = 0.0

	# Smoothly slew both players toward their targets simultaneously.
	_room3_player.volume_db = move_toward(
		_room3_player.volume_db, room3_target, ROOM3_VOLUME_SLEW * delta
	)
	_music_player.volume_db = move_toward(
		_music_player.volume_db, bg_target, ROOM3_VOLUME_SLEW * delta
	)
