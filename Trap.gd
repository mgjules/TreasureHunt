extends Area2D

signal trap_triggered
var active = true

func _on_Trap_area_entered(area):
	if active && area.is_in_group("player"):
		emit_signal("trap_triggered", 1)
		$AnimatedSprite.visible = true
		$Light2D.energy = 1
		$AnimatedSprite.play("activated")
		$AudioStreamPlayer2D.play()
		active = false
