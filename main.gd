extends Node

@onready var Click = $Battle/click
@onready var CanvasLayerrr = $Battle/CanvasLayer

func _ready():
	Click.visible = true
	CanvasLayerrr.visible = true

func _process(delta):
	if Input.is_action_just_pressed("whitespace"):
		if Click.visible:
			Click.visible = false
			CanvasLayerrr.visible = false
		else: 
			Click.visible = true
			CanvasLayerrr.visible = true
