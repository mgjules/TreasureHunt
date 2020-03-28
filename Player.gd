extends Area2D

var tile_size = 16
var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

onready var ray = $RayCast2D
onready var tween = $Tween

export var speed = 7

func _ready():
	$AnimationPlayer.play("light_idle")
	$AnimationPlayer.play("player_idle")
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	
func _process(delta):
	if tween.is_active():
		return
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			if dir == "right":
				$Sprite.scale.x = 1
			if dir == "left":
				$Sprite.scale.x = -1
			move(dir)

func move(dir):
    ray.cast_to = inputs[dir] * tile_size
    ray.force_raycast_update()
    if !ray.is_colliding():
        move_tween(dir)

func move_tween(dir):
    tween.interpolate_property(self, "position", position, position + inputs[dir] * tile_size, 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()

func _on_Tween_tween_started(object, key):
	$AnimationPlayer.play("player_run")
	$AudioStreamPlayer2D.play()

func _on_Tween_tween_completed(object, key):
	$AnimationPlayer.play("player_idle")
	$AudioStreamPlayer2D.stop()
	

