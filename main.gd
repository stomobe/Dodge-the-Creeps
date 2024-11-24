extends Node


@export var mob_scene: PackedScene
@export var orb_scene: PackedScene
var difficultyLevel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_difficulty(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func set_difficulty(levelNumber):
	difficultyLevel = levelNumber
	
	if difficultyLevel == 0:
		$PauseScreen/EasyButton.set_pressed_no_signal(true)
		$PauseScreen/NormalButton.set_pressed_no_signal(false)
		$PauseScreen/HardButton.set_pressed_no_signal(false)
	elif difficultyLevel == 1:
		$PauseScreen/EasyButton.set_pressed_no_signal(false)
		$PauseScreen/NormalButton.set_pressed_no_signal(true)
		$PauseScreen/HardButton.set_pressed_no_signal(false)
	else:
		$PauseScreen/EasyButton.set_pressed_no_signal(false)
		$PauseScreen/NormalButton.set_pressed_no_signal(false)
		$PauseScreen/HardButton.set_pressed_no_signal(true)


func _input(_event):
	if Input.is_action_just_pressed("pause_game"):
		get_viewport().set_input_as_handled()
		$HUD/ButtonSound.play()
		$PauseScreen.show()
		get_tree().paused = true


func game_over() -> void:
	GameState.player_is_dead = true
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$DeathBackground.set_color(Color("black", 0.8))
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("orbs", "queue_free")
	
	GameState.player_is_dead = false
	GameState.can_spawn_boss = true
	
	$DeathBackground.set_color(Color("black", 0.0))
	
	$Music.play()
	
	GameState.score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(GameState.score)
	$HUD.show_message("Get Ready")


func _on_score_timer_timeout() -> void:
	GameState.score += 1
	$HUD.update_score(GameState.score)


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	$OrbTimer.start()


func _on_mob_timer_timeout() -> void:
	# Mob spawn routine
	
	var spawn_chance
	var speed_scale
	var size_scale
	var will_spawn_boss = true if (GameState.can_spawn_boss && GameState.score > 100) else false
	
	# Set parameters based on difficulty level
	
	if difficultyLevel == 0:
		# Populate screen at beginning of game, then slow down spawn rate
		spawn_chance = 1.0 if GameState.score < 2 else 0.33
		
		speed_scale = 50.0 if will_spawn_boss else randf_range(80.0, 100.0)
		
		size_scale = 6.0 if will_spawn_boss else randf_range(0.5, 1.5)
	
	elif difficultyLevel == 1:
		spawn_chance = 0.67
		speed_scale = 50.0 if will_spawn_boss else randf_range(70.0, 275.0)
		size_scale = 8.0 if will_spawn_boss else randf_range(0.5, 2.0)
	
	else:
		spawn_chance = 1.00
		speed_scale = 50.0 if will_spawn_boss else randf_range(50.0, 500.0)
		size_scale = 12.0 if will_spawn_boss else randf_range(0.5, 2.0)
	
	
	# Check if skip mob creation based on spawn chance
	if spawn_chance <= randf_range(0.0, 1.00):
		return
	# Create a new instance of the Mob scene
	var mob = mob_scene.instantiate()
	
	
	# Choose a random location on Path2D
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	# Set the mob's direction perpendicular to the path direction
	var direction = mob_spawn_location.rotation + PI / 2
	
	# Set the mob's position to a random location
	mob.position = mob_spawn_location.position
	
	# Add some randomness to the direction
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Choose the velocity for the mob
	var velocity = Vector2(speed_scale, 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	# Change animation speed based on velocity
	mob.get_node("AnimatedSprite2D").set_speed_scale(speed_scale * 0.01)
	
	# Set size
	mob.resize(size_scale)
	
	
	# Spawn the mob by adding it to the Main scene
	if will_spawn_boss:
		GameState.can_spawn_boss = false
		$BossSpawnCoolDown.start()
		$BossSpawnSound.play()
		print("Boss Cooldown start")
	
	mob.add_to_group("enemies")
	
	add_child(mob)


func _on_orb_timer_timeout() -> void:
	if GameState.player_is_dead:
		return
	
	var orb = orb_scene.instantiate()
	
	# Choose random spawn location for orb, staying near center of screen
	var margin_size = 70
	var min_x = margin_size
	var max_x = $ColorRect.get_viewport_rect().size.x - margin_size
	var min_y = margin_size
	var max_y = $ColorRect.get_viewport_rect().size.y - margin_size
	orb.position = Vector2(randi_range(min_x, max_x), randi_range(min_y, max_y))
	
	# Spawn orb by adding it to Main scene
	orb.add_to_group("powerups")
	add_child(orb)


func _on_player_ate_orb(body) -> void:
	$Player.can_touch_orb = false
	body.set_deferred("disabled", true)
	
	body.orb_collected_sequence()
	
	await get_tree().create_timer(0.1).timeout
	$Player.can_touch_orb = true
	
	$OrbTimer.start() # spawn next orb


func _on_boss_spawn_cool_down_timeout() -> void:
	GameState.can_spawn_boss = true
	print("Boss Cooldown ended")
