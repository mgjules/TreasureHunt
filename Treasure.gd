extends Area2D

var tile_size = 16
signal treasure_collected
var active = true

func _ready():
	$AnimationPlayer.play("idle")
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	
func _on_Treasure_area_entered(area):
	if active && area.is_in_group("player"):
		emit_signal("treasure_collected")
		$AnimationPlayer.play("goaway")
		$AudioStreamPlayer2D.play()
		active = false
