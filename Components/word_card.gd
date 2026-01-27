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
		queue_free()

var is_game_going_check:Callable

signal word_finished
signal word_missed


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
	label.text = new_word
	# 更新首字母显示
	if new_word.length() > 0:
		big_letter_label.text = new_word[0]
		big_letter_label.modulate.a = 0  # 默认隐藏
	else:
		big_letter_label.text = ""

func play_letter_pop_animation():
	if word.length() == 0:
		return
	
	# 创建动画，首字母放大后消失
	var tween = create_tween()
	tween.set_parallel(true)
	
	var temp_label_node = big_letter_label.duplicate()
	panel_container.add_child(temp_label_node)
	
	# 显示临时label，显示当前首字母
	temp_label_node.text = word[0]
	temp_label_node.modulate.a = 1.0
	temp_label_node.scale = Vector2.ONE
	
	# 快速放大
	tween.tween_property(temp_label_node, "scale", Vector2(2.5, 2.5), 0.15)
	tween.tween_property(temp_label_node, "modulate:a", 1.0, 0.1)
	
	# 然后快速缩小并消失
	tween.chain().set_parallel(true)
	tween.tween_property(temp_label_node, "scale", Vector2(0.3, 0.3), 0.15)
	tween.tween_property(temp_label_node, "modulate:a", 0.0, 0.15)
	
	# 动画完成后释放节点
	tween.finished.connect(func(): temp_label_node.queue_free())

func _input(event):
	if not is_on_focus: return

	if event is InputEventKey and event.pressed and not event.echo:
		var keycode=event.keycode
		var ch=char(keycode)

		if word.length()>0 and word[0].to_lower()==ch.to_lower():
			# 播放首字母消失动画
			play_letter_pop_animation()
			# 移除首字母
			word = word.substr(1, word.length() - 1)
			if word == "":
				is_done = true

func _process(delta):
	if not is_game_going_check.call(): return
	position.y+=moving_speed*delta

	if position.y > get_viewport_rect().size.y and not is_done:
		is_done = true
		word_missed.emit()



func _ready() -> void:
	random_color()
