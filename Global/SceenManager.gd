extends Node

enum Page {
	MAIN,
	START
}

const PAGES_PATH = "res://Pages/"
const PAGE_FILES = {
	Page.MAIN: "main_page",
	Page.START: "start_page"
}

var audio_stream_player: AudioStreamPlayer
var switch_page_sound: AudioStream=preload("res://Assets/Sounds/kenney/tone1.mp3")

func switch_to_page(page: Page):
	var page_name = PAGE_FILES.get(page)
	if page_name:
		audio_stream_player.play()
		var full_path = PAGES_PATH + page_name + ".tscn"
		var error = get_tree().change_scene_to_file(full_path)
		if error != OK:
			push_error("Failed to load scene: " + full_path)

func _ready():
	audio_stream_player=AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = switch_page_sound