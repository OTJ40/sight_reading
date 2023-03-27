extends Control


enum STATE {
	PLAY,
	MENU
}

var all_notes_dict = {
	"c1": [Vector2i(0,142+16-34-17),"res://stem_down_extra.png"],
	"b": [Vector2i(0,142+16-34),"res://stem_down.png"],
	"a": [Vector2i(0,142+16-17),"res://stem_down.png"],
	"g": [Vector2i(0,142+16),"res://stem_down.png"],
	"f": [Vector2i(0,142+16+17),"res://stem_down.png"],
	"e": [Vector2i(0,142+16+35),"res://stem_down.png"],
	"d": [Vector2i(0,142+16+35+17),"res://stem_down.png"],
	"c": [Vector2i(0,142+16+35+35-32),"res://stem_up.png"],
	"B": [Vector2i(0,142+16+35+35+17-32),"res://stem_up.png"],
	"A": [Vector2i(0,142+16+35+35+35-32),"res://stem_up.png"],
	"G": [Vector2i(0,142+16+35+35+35+18-32),"res://stem_up.png"],
	"F": [Vector2i(0,142+16+35+35+35+34-32),"res://stem_up.png"],
	"E": [Vector2i(0,142+16+34+34+34+34+17-32),"res://stem_up_extra.png"],
}

var flats = [
	Vector2i(132,240),
	Vector2i(132,184),
	Vector2i(132,254),
	Vector2i(132,204)
]

var sharps = [
	Vector2i(132,176),
	Vector2i(132,228),
	Vector2i(132,158),
	Vector2i(132,210)
]

@export var BTN_DELAY = 0.5
@export var MENU_DELAY = 0.5
var note_scene: PackedScene
var sign_scene: PackedScene

var is_menu_out = false
var is_signs_enabled = false
var is_max_enabled = false
var is_timer_enabled = false

var not_e_natural = false
var is_timer_on = false
var max_interval = 0
var if_sign = 0
var btn_timer = Timer.new()
var menu_timer = Timer.new()
var play_timer = Timer.new()
var state = STATE.PLAY


@onready var sign_group: ButtonGroup = $HBoxContainer/NavPanel/VBoxContainer/SignsContainer/HBoxContainer/Button.button_group
@onready var interval_group: ButtonGroup = $HBoxContainer/NavPanel/VBoxContainer/IntervalContainer/HBoxContainer/Button.button_group
@onready var timer_group: ButtonGroup = $HBoxContainer/NavPanel/VBoxContainer/TimerContainer/HBoxContainer/Button.button_group

func _ready() -> void:
	
	randomize()
	
	$HBoxContainer/NavPanel.set_stretch_ratio(0.3)
	
	note_scene = load("res://note.tscn")
	sign_scene = load("res://sign.tscn")
	
	btn_timer.timeout.connect(_enable_change_btn)
	btn_timer.one_shot = true
	add_child(btn_timer)
	
	menu_timer.timeout.connect(_enable_menu)
	menu_timer.one_shot = true
	add_child(menu_timer)
	
	play_timer.one_shot = true
	add_child(play_timer)


func _process(delta: float) -> void:
	if state == STATE.MENU:
		$HBoxContainer2/Activity/ChangeButton.disabled = true
	if state == STATE.PLAY:
		$HBoxContainer2/Activity/ChangeButton.disabled = true if is_timer_enabled or !btn_timer.is_stopped() else false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenDrag:
		if (abs(event.relative.x) - abs(event.relative.y)) > 5:
			menu_timer.start(MENU_DELAY)
			if event.relative.x < 0 and !is_menu_out:
				$HBoxContainer/NavPanel/AnimationPlayer.play("pull_out")
				is_menu_out = true
				state = STATE.MENU
				if is_timer_enabled:
					play_timer.stop()
				$HBoxContainer2/Activity/ChangeButton.disabled = true
				$HBoxContainer/NavPanel/Area2D/CollisionShape2D.shape.size.x = 0
				
				$HBoxContainer/NavPanel/VBoxContainer/SignsContainer.visible = is_signs_enabled
				$HBoxContainer/NavPanel/VBoxContainer/IntervalContainer.visible = is_max_enabled
				$HBoxContainer/NavPanel/VBoxContainer/TimerContainer.visible = is_timer_enabled
			elif event.relative.x > 0 and is_menu_out:
				state = STATE.PLAY
				if is_timer_enabled:
					is_timer_on = true
					_on_change_button_button_up()
				is_menu_out = false
				
				$HBoxContainer/NavPanel/AnimationPlayer.play("pull_in")
				$HBoxContainer/NavPanel/Area2D/CollisionShape2D.shape.size.x = 0
				
				$HBoxContainer/NavPanel/VBoxContainer/SignsContainer.visible = false
				$HBoxContainer/NavPanel/VBoxContainer/IntervalContainer.visible = false
				$HBoxContainer/NavPanel/VBoxContainer/TimerContainer.visible = false

func start():
	$HBoxContainer.mouse_filter = MOUSE_FILTER_STOP
	$Control/Label.text = "Press To Start"
	$Control/Label.visible = true
	for i in range(3,0,-1):
		$Control/Label.text = str(i)
		await get_tree().create_timer(1).timeout
	$Control/Label.visible = false
	is_timer_on = false
	$HBoxContainer.mouse_filter = MOUSE_FILTER_IGNORE

func push_front_signs():
	if is_signs_enabled:
		var num_of_signs = randi() % (int(sign_group.get_pressed_button().text) + 1)
		if num_of_signs:
			var sign_chance = randi() % 4 + 1
			var sign_name = ""
			match sign_chance:
				1,3:
					# c-dur
					if_sign = 0
				2:
					# flats
					if_sign = 64
					sign_name = "flat"
				4:
					# sharps
					if_sign = 64
					sign_name = "sharp"
			if sign_name == "flat" and num_of_signs > 1:
				not_e_natural = true
			var c = Control.new()
			c.custom_minimum_size = Vector2i(if_sign,0)
			$HBoxContainer2/Activity/HBoxContainer.add_child(c,false,Node.INTERNAL_MODE_FRONT)
			if if_sign:
				var ar = []
				ar.append_array(flats if sign_name == "flat" else sharps)
				for i in range(num_of_signs,0,-1):
					var s = get_sign_instance(sign_name)
					s.position = ar[num_of_signs - i] + Vector2i(12*(4-i),0)
					$Notes.add_child(s)



func _on_change_button_button_up() -> void:
	clear_stave()
	if is_timer_on:
		await start()
	if is_timer_enabled:
		push_front_signs()
		get_new_phrase()
		play_timer.start(int(timer_group.get_pressed_button().text))
		await play_timer.timeout
		_on_change_button_button_up()
	else:
#		$HBoxContainer2/Activity/ChangeButton.disabled = true
		btn_timer.start(BTN_DELAY)
		push_front_signs()
		get_new_phrase()

func get_new_phrase():
	var count = 0
	var temp
	if not_e_natural:
		temp = randi() % (all_notes_dict.size()-1)
	else:
		temp = randi() % (all_notes_dict.size())
	$Notes.add_child(get_note_instance(temp,count))
	count += 1
	
	for i in range(7):
		if is_max_enabled:
			var max_interval = int(interval_group.get_pressed_button().text) - 1
			var idx = randi_range(0 - max_interval,max_interval)
			if ((temp + idx) < 0 or (temp + idx) > all_notes_dict.size()-1) or (not_e_natural and (temp + idx) == all_notes_dict.size()-1):
				idx = 0 - idx
			temp += idx
				
			$Notes.add_child(get_note_instance(temp,count))
		else:
			var idx = randi() % (all_notes_dict.size()-1) if not_e_natural else randi() % (all_notes_dict.size())
			$Notes.add_child(get_note_instance(idx,count))
		count += 1
	not_e_natural = false

func get_sign_instance(name: String):
	var s = sign_scene.instantiate()
	s.get_child(0).texture = load(name + ".png")
	return s

func get_note_instance(i: int,offset_count: int):
	var n = note_scene.instantiate()
	n.position = all_notes_dict[all_notes_dict.keys()[i]][0] + Vector2i(148+16+20+if_sign/2,0) + Vector2i(offset_count*70,0)
	n.get_child(0).texture = load(all_notes_dict[all_notes_dict.keys()[i]][1])
	return n

func clear_stave():
	for item in $Notes.get_children():
		item.queue_free()
	var children_of_front = $HBoxContainer2/Activity/HBoxContainer.get_children(true)
	if children_of_front.size() > 1:
		for i in children_of_front.size()-1:
			children_of_front[i].queue_free()
	if_sign = 0

func _on_sign_check_button_toggled(button_pressed: bool) -> void:
	is_signs_enabled = true if button_pressed else false
	$HBoxContainer/NavPanel/VBoxContainer/SignsContainer.visible = true if button_pressed else false


func _on_interval_check_button_toggled(button_pressed: bool) -> void:
	is_max_enabled = true if button_pressed else false
	$HBoxContainer/NavPanel/VBoxContainer/IntervalContainer.visible = true if button_pressed else false


func _on_timer_check_button_toggled(button_pressed: bool) -> void:
	is_timer_enabled = true if button_pressed else false
	$HBoxContainer/NavPanel/VBoxContainer/TimerContainer.visible = true if button_pressed else false

func _enable_change_btn():
	$HBoxContainer2/Activity/ChangeButton.disabled = false

func _enable_menu():
	if state == STATE.MENU:
		$HBoxContainer/NavPanel/Area2D/CollisionShape2D.shape.size.x = 300
	if state == STATE.PLAY:
		$HBoxContainer/NavPanel/Area2D/CollisionShape2D.shape.size.x = 82
