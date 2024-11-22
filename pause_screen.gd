extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func resume_game():
	hide()
	get_tree().paused = false


func _input(event):
	if Input.is_action_just_pressed("pause_game"):
		get_viewport().set_input_as_handled()
		resume_game()


func _on_button_pressed() -> void:
	resume_game()
