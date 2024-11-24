extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_despawn_timer_timeout() -> void:
	# Automatically despawn mob after staying on screen for too long
	queue_free()


func resize(scale: float) -> void:
	var scaleVector = Vector2(scale, scale)
	$AnimatedSprite2D.scale *= scaleVector
	$CollisionShape2D.scale *= scaleVector
