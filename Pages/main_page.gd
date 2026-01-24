extends Node2D

var word_list:Array = []

var word_card_scene:PackedScene=preload("res://Components/word_card.tscn")
var game_over_sceen:PackedScene=preload("res://Components/game_over_sceen.tscn")

var word_card_queue: Queue = Queue.new()


@onready var hp_label: Label = $HpLabel
@onready var word_generation_timer: Timer = $WordGenerationTimer
@onready var cards: Node2D = $Cards

var is_gaming_going:bool=true

var time_delta_min:float=1
var time_delta_max:float=3

var hp:int=3:
	get:
		return hp
	set(value):
		hp = value
		hp_label.text = "hp: %d" % hp

var score:int=0:
	get:
		return score
	set(value):
		score = value
		$SacoreLabel.text = "Score: %d" % score

func load_words(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var content = file.get_as_text()
		word_list = Array(content.split("\n", false))
		file.close()

func generate_word_card(word:String):
	var word_card = word_card_scene.instantiate()
	cards.add_child(word_card)
	word_card.is_game_going_check=func(): return is_gaming_going
	word_card.word = word
	word_card.position.y = -10
	

	
	word_card_queue.push(word_card)

	# 连接信号
	word_card.connect("word_missed", Callable(self, "word_miss"))
	word_card.connect("word_finished", Callable(self, "word_finish"))
	
	# 确保卡片完全显示在屏幕内
	var screen_width = get_viewport_rect().size.x
	var card_width = word_card.panel_container.size.x
	word_card.position.x = randf_range(0, screen_width - card_width)

func word_miss():
	hp -= 1
	if(hp <= 0):
		game_over()
	else:
		clear_window()
		await word_generation_timer.timeout
		next_card_focus()
	

func word_finish():
	score+=1
	next_card_focus()

func next_card_focus():
	while word_card_queue.size() > 0:
		var word_card = word_card_queue.pop()
		if is_instance_valid(word_card) and not word_card.is_done:
			word_card.is_on_focus = true
			return

func clear_window():
	# 清理所有正在显示的单词卡片
	for child in cards.get_children():
		if child is WordCard:
			child.is_done = true
			child.queue_free()
	
	# 清空队列
	while word_card_queue.size() > 0:
		word_card_queue.pop()

func game_over():
	var game_over_screen_instance = game_over_sceen.instantiate()
	add_child(game_over_screen_instance)
	
	
	var screen_size = get_viewport_rect().size
	game_over_screen_instance.position = (screen_size - game_over_screen_instance.size) / 2
	
	game_over_screen_instance.score = score
	game_over_screen_instance.visible = true
	is_gaming_going = false

func game_start():
	while is_gaming_going:
		if word_list.size() > 0:
			generate_word_card(word_list.pick_random())

		var delta_time:float=randf_range(time_delta_min,time_delta_max)
		word_generation_timer.wait_time = delta_time
		word_generation_timer.start()

		await word_generation_timer.timeout

func _ready():
	hp=1
	score=0
	load_words("res://Assets/words.txt")
	game_start()
	next_card_focus()
