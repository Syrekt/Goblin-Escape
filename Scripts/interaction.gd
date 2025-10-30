class_name Interaction extends Area2D

@export var interactable := true
@export var auto := false
@export var repeat := false
@export var title : String ## Text that shows besides the button prompt

var active := false
var waiting_player_exit := false

@export_multiline var interaction_speech : String

signal interacted
