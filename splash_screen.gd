extends Control

func _ready() -> void:
	$AnimationPlayer.play("splash")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://nav_panel_main_2.tscn")
