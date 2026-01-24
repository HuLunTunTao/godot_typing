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

func switch_to_page(page: Page):
	var page_name = PAGE_FILES.get(page)
	if page_name:
		var full_path = PAGES_PATH + page_name + ".tscn"
		var error = get_tree().change_scene_to_file(full_path)
		if error != OK:
			push_error("Failed to load scene: " + full_path)

