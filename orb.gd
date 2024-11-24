extends RigidBody2D


signal collected


var orb_score_value = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnSound.play()
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func orb_collected_sequence():
	$PickupSound.play()
	$AnimatedSprite2D.play("collected")
	
	GameState.score += orb_score_value
	
	$PlusScore.position = $AnimatedSprite2D.position
	$PlusScore.visible = true
	await get_tree().create_timer(0.6).timeout
	$PlusScore.visible = false


func _on_pickup_sound_finished() -> void:
	queue_free()
