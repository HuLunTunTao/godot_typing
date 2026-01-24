extends Node2D

var word_list:Array = []

var word_card_scene:PackedScene=preload("res://Components/WordsCard.tscn")

var word_card_queue: Queue = Queue.new()


@onready var hp_label: Label = $HpLabel
@onready var word_generation_timer: Timer = $WordGenerationTimer


var time_delta_min:float=0.5
var time_delta_max:float=1.5

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
	word_card.word = word
	word_card.position.y = -10
	add_child(word_card)

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

	next_card_focus()

func word_finish():
	score+=1

	next_card_focus()

func next_card_focus():
	var word_card=word_card_queue.pop()
	while word_card.is_done:
		word_card=word_card_queue.pop()

	word_card.is_on_focus=true
	

func game_over():
	print("game over")



func game_start():
	while true:
		if word_list.size() > 0:
			generate_word_card(word_list.pick_random())

		var delta_time:float=randf_range(time_delta_min,time_delta_max)
		word_generation_timer.wait_time = delta_time
		word_generation_timer.start()

		await word_generation_timer.timeout

func _ready():
	hp=0
	score=0
	load_words("res://Assets/words.txt")
	game_start()