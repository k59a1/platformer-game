extends Node2D

@onready var animation_player = get_node("ColorRect2/AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("ColorRect").show()
	get_node("ColorRect2").hide()
	await get_tree().create_timer(0.2).timeout
	get_node("ColorRect").hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_node("ColorRect2").show()
	animation_player.play("fade out")
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/quotes.tscn")
