extends CanvasLayer


func change_scene(target: String) -> void:
	print("changing")
	$AnimationPlayer.play("dissolve")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(target)
	$AnimationPlayer.play_backwards("dissolve")
	#$AnimationPlayer.play("RESET")

func reload():
	$AnimationPlayer.play("dissolve")
	yield($AnimationPlayer, "animation_finished")
	get_tree().reload_current_scene()
	$AnimationPlayer.play_backwards("dissolve")
