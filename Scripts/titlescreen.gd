extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	get_node("ColorRect/AnimationPlayer").play("fade out 2")
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/level_scene.tscn")

func _on_button_settings_pressed() -> void:
	get_node("ColorRect/AnimationPlayer").play("fade out 2")
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_button_quit_pressed() -> void:
	get_node("ColorRect").show()
	get_node("ColorRect/AnimationPlayer").play("fade out 2")
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _on_button_credits_pressed() -> void:
	get_node("ColorRect").show()
	get_node("ColorRect/AnimationPlayer").play("fade out 2")
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
