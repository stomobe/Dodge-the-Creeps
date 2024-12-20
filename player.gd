extends Area2D


signal hit
signal ate_orb(body)


@export var speed = 400 # How fast the player will move (pixels/sec)
var screen_size # Size of the game window
var can_touch_orb = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
		# Rotate sprite in the direction of velocity
		var angleOfMovement = velocity.angle() + PI / 2
		$AnimatedSprite2D.rotation = angleOfMovement
		$CollisionShape2D.rotation = angleOfMovement
		
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		#$AnimatedSprite2D.flip_v = velocity.y > 0

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print("hit mob")
	
		hide() # Player disappears after being hit
		hit.emit()
		# Must be deferred as we can't change physics properties on a physics callback
		$CollisionShape2D.set_deferred("disabled", true)

	elif body.is_in_group("powerups"):
		if can_touch_orb:
			print("ate orb")
			ate_orb.emit(body)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
