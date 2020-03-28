extends Node2D

var treasure_collected = 0
var total_treasures = 0
export var player_hp = 5
export var time_left = 60

var tutorial_running  = false
var tutorial_dialog = [
	"Collect all the treasures!",
	"Use WASD to move",
	"Beware of red glows!",
	"Press 'R' to restart",
	"Don't run out of time!",
	"That's all!",
]
var tutorial_dialog_current = 0
var tutorial_area_exited = false

func _ready():
	total_treasures = get_tree().get_nodes_in_group("treasures").size();
	updateTreasuresLabel()
	updateTimeLabel()
	updatePlayerHP()
	$DialogBox/AnimationPlayer.play("idle")
	say("Pssstt!! Need help?")

func _on_Treasure_treasure_collected():
	treasure_collected += 1
	updateTreasuresLabel()
	if treasure_collected == total_treasures:
		congrat()
	
func updateTreasuresLabel():
	$CanvasLayer/HUD/HBoxContainer2/TRVal.text = str(treasure_collected) + "/" + str(total_treasures)

func updatePlayerHP():
	$CanvasLayer/HUD/HBoxContainer/HPLabel.text = ""
	for i in player_hp:
		$CanvasLayer/HUD/HBoxContainer/HPLabel.text += "♥"

func updateTimeLabel():
	$CanvasLayer/HUD/HBoxContainer3/TimeVal.text = str(time_left)
	
func takeDamage(damage):
	player_hp -= damage
	$Player/AnimationPlayer.play("player_damage")
	if player_hp <= 0:
		player_hp = 0
		gameOver("You died in an unexciting way!")
	updatePlayerHP()
	
func congrat():
	$CanvasLayer/SUCCESS.show()
	stopTheWorld()
	
func gameOver(reason):
	$CanvasLayer/FAIL/VBoxContainer/Reason.text = reason
	$CanvasLayer/FAIL.show()
	stopTheWorld()
	
func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		$CanvasLayer/RESTART.visible = !$CanvasLayer/RESTART.visible
		if $CanvasLayer/RESTART.visible:
			stopTheWorld()
		else:
			resumeTheWorld()
	if event.is_action_pressed("menu"):
		if $CanvasLayer/FAIL.visible || $CanvasLayer/SUCCESS.visible:
			get_tree().change_scene("res://Main.tscn")
			return
		if $CanvasLayer/RESTART.visible:
			$CanvasLayer/RESTART.hide()
			resumeTheWorld()
			return
		$CanvasLayer/QUIT.visible = !$CanvasLayer/QUIT.visible
		if $CanvasLayer/QUIT.visible:
			stopTheWorld()
		else:
			resumeTheWorld()
			
func resumeTheWorld():
	$Timer.set_paused(false)
	$DialogBox/Dialog/DialogTimer.set_paused(false)
	$Player.set_process(true)
	
func stopTheWorld():
	$Timer.set_paused(true)
	$DialogBox/Dialog/DialogTimer.set_paused(true)	
	$Player.set_process(false)
	
func say(text):
	$DialogBox/Dialog.text = text
	if text != "":
		$DialogBox/Dialog/DialogTimer.start()
		
func start_tutorial():
	if !tutorial_running && tutorial_dialog_current < len(tutorial_dialog):
		tutorial_running = true
		say_tutorial_dialog_next()
			
func stop_tutorial():
	tutorial_running = false

func say_tutorial_dialog_next():
	if !tutorial_running:
		return
	if tutorial_dialog_current >= len(tutorial_dialog):
		say("I don't have any more tip")
		$DialogBox/AnimationPlayer.play("fades out")
		stop_tutorial()
		return
	say(tutorial_dialog[tutorial_dialog_current])
	tutorial_dialog_current += 1

func _on_Timer_timeout():
	if time_left > 0:
		time_left -= 1
		updateTimeLabel()
	else:
		gameOver("Seriously? How did you run out of time?!?")

func _on_Trap_trap_triggered(damage):
	takeDamage(damage)

func _on_Yes_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_No_pressed():
	$CanvasLayer/QUIT.hide()
	resumeTheWorld()

func _on_YesFail_pressed():
	$CanvasLayer/FAIL.hide()
	get_tree().reload_current_scene()
	
func _on_NoFail_pressed():
	get_tree().change_scene("res://Main.tscn")
	
func _on_YesSucc_pressed():
	$CanvasLayer/SUCCESS.hide()
	get_tree().reload_current_scene()
	
func _on_NoSucc_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_DialogTimer_timeout():
	say("")
	if tutorial_running:
		say_tutorial_dialog_next()

func _on_YesRestart_pressed():
	get_tree().reload_current_scene()
	$CanvasLayer/RESTART.hide()

func _on_NoRestart_pressed():
	$CanvasLayer/RESTART.hide()

func _on_DialogPad_area_entered(area):
	if !tutorial_running && area.is_in_group("player"):
		start_tutorial()

func _on_DialogPad_area_exited(area):
	if tutorial_running && area.is_in_group("player"):
		stop_tutorial()
		if tutorial_dialog_current < len(tutorial_dialog):
			say("Hey, come back! I'm not over yet!")
		else:
			$DialogBox/AnimationPlayer.play("fades out")
			
func _on_DialogSpace_area_exited(area):
	if !area.is_in_group("player"):
		return
	if !tutorial_area_exited && tutorial_dialog_current == 0:
		say("You don't need my help? Well goodluck!")
		tutorial_area_exited = true
	elif tutorial_area_exited && tutorial_dialog_current == 0:
		say("You are on your own!")
		$DialogBox/AnimationPlayer.play("fades out")
		tutorial_dialog_current = len(tutorial_dialog)

func _on_DialogSpace_area_entered(area):
	if !area.is_in_group("player"):
		return
	if tutorial_area_exited && tutorial_dialog_current == 0:
		say("Ah! You changed your mind")
