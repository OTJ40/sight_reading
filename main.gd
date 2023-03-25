extends Control


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

@export var BTN_DELAY = 0.5
var scene: PackedScene
var btn_timer = Timer.new()
var if_sign = 0

func _ready() -> void:
	randomize()
	scene = load("res://note.tscn")
	
	btn_timer.timeout.connect(_en_btn)
	btn_timer.one_shot = true
	add_child(btn_timer)

func _en_btn():
	$Screen/ScreenBackground/ChangeButton.disabled = false

func clear_stave():
	for item in $Notes.get_children():
		item.queue_free()
	var children_of_front = $Screen/ScreenBackground/StaveContainer/HBoxContainer.get_children(true)
	if children_of_front.size() > 1:
		children_of_front[0].queue_free()

func get_new_phrase():
	var count = 0
	for i in range(8):
		var idx = randi() % all_notes_dict.size()
		var n = scene.instantiate()
#		n.texture = s
		n.position = all_notes_dict[all_notes_dict.keys()[idx]][0] + Vector2i(95+16+20+if_sign/2,0) + Vector2i(count*70,0)
		count += 1
		n.get_child(0).texture = load(all_notes_dict[all_notes_dict.keys()[idx]][1])
#		match all_notes.keys()[idx]:
#			""
		$Notes.add_child(n)

func push_front_signs():
	var sign_chance = randi() % 4 + 1
	var num_of_signs = randi() % 4 + 1
	match sign_chance:
		1,3:
			# c-dur
			if_sign = 0
		2:
			# flats
			if_sign = 64
		4:
			# sharps
			if_sign = 64
	var c = Control.new()
	c.custom_minimum_size = Vector2i(if_sign,0)
	$Screen/ScreenBackground/StaveContainer/HBoxContainer.add_child(c,false,Node.INTERNAL_MODE_FRONT)

func _on_change_button_button_up() -> void:
	$Screen/ScreenBackground/ChangeButton.disabled = true
	btn_timer.start(BTN_DELAY)
	clear_stave()
	push_front_signs()
	get_new_phrase()
