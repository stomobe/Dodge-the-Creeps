extends CanvasLayer


signal difficultyLevelSelected(level)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func resume_game():
	hide()
	get_tree().paused = false


func _input(_event):
	if Input.is_action_just_pressed("pause_game"):
		get_viewport().set_input_as_handled()
		$ButtonSound.play()
		resume_game()


func _on_button_pressed() -> void:
	$ButtonSound.play()
	resume_game()


func _on_easy_button_pressed() -> void:
	$SwitchSound.play()
	difficultyLevelSelected.emit(0)


func _on_normal_button_pressed() -> void:
	$SwitchSound.play()
	difficultyLevelSelected.emit(1)


func _on_hard_button_pressed() -> void:
	$SwitchSound.play()
	difficultyLevelSelected.emit(2)
