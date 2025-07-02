extends Node

@onready var Battle = $Battle/click

func _ready():
	Battle.visible = false

func _process(delta):
	if Input.is_action_just_pressed("whitespace"):
		if Battle.visible:
			Battle.visible = false
		else: 
			Battle.visible = true
