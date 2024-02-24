extends Node

var camera : Camera2D
var player : CharacterBody2D
var gameIsStarted = false
	
func frameFreeze(time_scale, duration):
	Engine.time_scale = time_scale
	await(get_tree().create_timer(duration * time_scale).timeout)
	Engine.time_scale = 1.0
