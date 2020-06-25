extends Node2D

onready var body:Sprite=$Body
onready var head:Sprite=$Head
onready var hair:Sprite=$Hair
onready var label:Label=$Label
onready var eyes:Sprite=$Eyes
onready var nosemouth:Sprite=$NoseMouth
onready var boxes:Sprite=$Boxes

#variations for cloth colors
const num_of_var:int=4
var rand_cloth:int
var cloth_colors:Array=[Color8(113, 11, 9),Color8(40, 24, 78),Color8(19, 64, 83),Color8(37, 86, 78)]

#colors for the face/body
var body_colors:Array=[Color8(242, 95, 92),Color8(112, 193, 179),Color8(36, 123, 160),Color8(81, 49, 155)]


func _ready():
	randomize()
# warning-ignore:narrowing_conversion
	rand_cloth=floor(rand_range(0,4))

func set_character(input,num):
	head.visible=true
	body.visible=true
	eyes.visible=true
	nosemouth.visible=true
	hair.visible=true
	label.visible=true
	boxes.visible=true
		
	head.modulate=body_colors[input[0]]
	head.frame=input[1]
	body.frame=input[2]
	eyes.frame=input[3]
	nosemouth.frame=input[4]
	hair.frame=input[5]
	label.text=str(num+1)
	body.modulate=cloth_colors[rand_cloth]
	
