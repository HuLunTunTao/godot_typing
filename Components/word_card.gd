class_name WordCard
extends Node2D

var word:String="hello":
	get:
		return word
	set(value):
		word = value
		change_label_word(word)
		if value=="":
			word_finished.emit()
			is_done=true
		

var is_on_focus:bool=false:
	get:
		return is_on_focus
	set(value):
		is_on_focus = value
		highlight()

var moving_speed:int=100

var is_done:bool=false: #finished获missed了
	set(value):
		is_done = value
		visible=false
		clean()

var is_animating:bool=false  # 动画期间标志

var is_game_going_check:Callable

signal word_finished
signal word_missed

signal input_correct
signal input_wrong


var colors: Array[Color] = [
	Color(0.75, 0.15, 0.15), # 深红
	Color(0.80, 0.35, 0.10), # 深橙
	Color(0.70, 0.55, 0.05), # 琥珀
	Color(0.55, 0.65, 0.05), # 橄榄绿
	Color(0.15, 0.65, 0.25), # 翡翠绿
	Color(0.05, 0.60, 0.45), # 深青
	Color(0.10, 0.55, 0.75), # 深天蓝
	Color(0.15, 0.35, 0.85), # 深宝蓝
	Color(0.35, 0.25, 0.85), # 靛青
	Color(0.55, 0.15, 0.85), # 深紫
	Color(0.75, 0.15, 0.65), # 玫紫
	Color(0.75, 0.10, 0.40)  # 深玫瑰粉
]



@onready var panel_container: PanelContainer = $PanelContainer
@onready var label: Label = $PanelContainer/Label
@onready var big_letter_label: Label = $PanelContainer/BigLetterLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var clean_timer: Timer = $CleanTimer

var sound_effect_max_length:float

func random_color():
	if colors and colors.size() > 0:
		var style_box = panel_container.get_theme_stylebox("panel").duplicate()
		style_box.bg_color = colors.pick_random()
		panel_container.add_theme_stylebox_override("panel", style_box)

func highlight():
	var style_box = panel_container.get_theme_stylebox("panel").duplicate()
	style_box.set_border_width_all(4)
	style_box.border_color = Color.WHITE
	panel_container.add_theme_stylebox_override("panel", style_box)

func change_label_word(new_word: String):
	if is_animating:
		return  # 动画期间不更新
	
	label.text = new_word
	# 更新首字母显示 - 首字母+其余空格，保持单词长度
	if new_word.length() > 0:
		var spaces = " ".repeat(new_word.length() - 1)
		big_letter_label.text = new_word[0] + spaces
		big_letter_label.modulate.a = 0  # 默认隐藏
	else:
		big_letter_label.text = ""

func play_letter_pop_animation():
	if word.length() == 0:
		return
	
	# 保存首字母和剩余字母
	var first_letter = word[0]
	var remaining = word.substr(1)
	
	# 创建临时节点用于动画
	var temp_node = big_letter_label.duplicate()
	panel_container.add_child(temp_node)
	
	# 临时节点显示：首字母+空格（保持原位置）
	var spaces = " ".repeat(word.length() - 1)
	temp_node.text = first_letter + spaces
	temp_node.modulate.a = 1.0
	temp_node.scale = Vector2.ONE
	
	# 将label的首字母替换为空格，保持位置
	label.text = " " + remaining
	
	# 立即修改word，不阻滞用户输入
	is_animating = true
	word = remaining
	is_animating = false
	
	# 创建动画，首字母放大后消失
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 快速放大
	tween.tween_property(temp_node, "scale", Vector2(2, 2), 0.25)
	tween.tween_property(temp_node, "modulate:a", 1.0, 0.25)
	
	# 然后快速缩小并消失
	tween.chain().set_parallel(true)
	tween.tween_property(temp_node, "scale", Vector2(0.3, 0.3), 0.1)
	tween.tween_property(temp_node, "modulate:a", 0.0, 0.1)
	
	# 动画完成后清理
	tween.finished.connect(func():
		temp_node.queue_free()
	)


func _input(event):
	if not is_on_focus: return

	if event is InputEventKey and event.pressed and not event.echo:
		var keycode=event.unicode
		
		if event.unicode != 0 and word.length()>0:
			var ch=char(keycode)

			if word[0].to_lower()==ch.to_lower():
				# 播放首字母消失动画（动画结束后会自动删除首字母）
				input_correct.emit()
				play_letter_pop_animation()
			else:
				input_wrong.emit()

func _process(delta):
	if not is_game_going_check.call(): return
	position.y+=moving_speed*delta

	if position.y > get_viewport_rect().size.y and not is_done:
		is_done = true
		word_missed.emit()

var is_waiting_for_cleaning:bool=false
func clean():
	if is_waiting_for_cleaning:return
	is_waiting_for_cleaning = true
	clean_timer.start()
	await clean_timer.timeout

	queue_free()

func _ready() -> void:
	random_color()
