class_name StatusEffect extends Node

var value : float
var effect : String
var persistent := false ## Don't remove on rest if persistent, has to remove manually using other methods
var half_time_ticked := false ## Used to trigger Kalin's thoughts
