class_name Interaction extends Area2D

@export var auto := false
@export var repeat := false
@export var title : String ## Text that shows besides the button prompt

var active := false
var waiting_player_exit := false
