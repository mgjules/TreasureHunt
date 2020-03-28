extends StaticBody2D

var tile_size = 16

func _ready():
    position = position.snapped(Vector2.ONE * tile_size)
    position += Vector2.ONE * tile_size/2
