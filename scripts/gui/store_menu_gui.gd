extends Control

signal opened
signal closed

var isOpen: bool = false

func open():
	visible = true
	isOpen = true
	emit_signal("opened")
	
func close():
	visible = false
	isOpen = false
	emit_signal("closed")
