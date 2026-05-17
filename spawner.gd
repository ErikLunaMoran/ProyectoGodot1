extends Node2D

@export var player : CharacterBody2D
@export var enemy : PackedScene

var distance : float = 400

@export var enemy_types : Array[Enemy]

var minute : int:
	set(value):
		minute = value
		%Minute.text = str(value)

var second : int:
	set(value):
		second = value
		if second >= 10: #set 60
			second -= 10
			minute += 1
		%Second.text = str(second).lpad(2,'0')

func spawn(pos : Vector2):
	var enemy_instance = enemy.instantiate()
	
	enemy_instance.type = enemy_types[min(minute, enemy_types.size()-1)]
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	
	get_tree().current_scene.add_child(enemy_instance)

#Function to get random position from player at a particular distance
func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0,2 * PI))

#spawn multiple enemy at a time
func amount(number : int = 1):
	for i in range(number):
		spawn(get_random_position())
		



func _on_timer_timeout():
	second += 1
	amount(second % 10)

#Enemies coming in circular shape
func _on_pattern_timeout():
	for i in range(75):
		spawn(get_random_position())
