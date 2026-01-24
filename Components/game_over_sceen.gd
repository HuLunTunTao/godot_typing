extends Control

@onready var label: Label = $ColorRect/Label

var score:int=0:
	get:
		return score
	set(value):
		score = value
		label.text = "Game Over\nScore: %d" % score

func _on_back_start_button_pressed() -> void:
	SceenManager.switch_to_page(SceenManager.Page.START)
