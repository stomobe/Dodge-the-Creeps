extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])
	
	# Randomize mob size
	var scaleFactor = Vector2.ONE * randf_range(0.5, 2.00)
	$AnimatedSprite2D.scale *= scaleFactor
	$CollisionShape2D.scale *= scaleFactor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_despawn_timer_timeout() -> void:
	# Automatically despawn mob after staying on screen for too long
	queue_free()
