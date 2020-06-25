extends Node2D

onready var color:Sprite=$CluesColor
onready var body:Sprite=$CluesBody
onready var head:Sprite=$CluesHead
onready var eyes:Sprite=$CluesEyes
onready var nosemouth:Sprite=$CluesNoseMouth
onready var hair:Sprite=$CluesHair

onready var hand:Sprite=$HandFinger

#array to highlight wrong clues
onready var not_array:Array=[$Wrong0, $Wrong1, $Wrong2, $Wrong3, $Wrong4, $Wrong5]

#face colors
var colors1:Array=[Color8(242, 95, 92),Color8(112, 193, 179),Color8(36, 123, 160),Color8(81, 49, 155)]

#variations of each characteristics
const num_of_var:int=4

#criminal characteristics and suspects
var criminal_array_clues:Array
var suspects_array_clues:Array
var not_value:int

func _ready():
	#color the hand holding the folder
	randomize()
	var rand=floor(rand_range(0,colors1.size()))
	hand.modulate=colors1[rand]

#main function, ch for characteristics
func set_clues(criminal, suspects):
	#hide highlights
	for i in range(criminal.size()):
		not_array[i].visible=false
	#assign values to clues
	color.modulate=colors1[criminal[0]]
	head.frame=criminal[1]
	body.frame=criminal[2]
	eyes.frame=criminal[3]
	nosemouth.frame=criminal[4]
	hair.frame=criminal[5]

	#save criminal data and suspects for the future
	criminal_array_clues=criminal.duplicate(true)
	suspects_array_clues=suspects.duplicate(true)

func highlight_difference(id_selected):
	for i in range(criminal_array_clues.size()):
		if suspects_array_clues[id_selected][i]!=criminal_array_clues[i]:
				not_array[i].visible=true
