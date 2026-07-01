extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("ColorRect").show()
	await get_tree().create_timer(0.6).timeout
	get_node("ColorRect").hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
