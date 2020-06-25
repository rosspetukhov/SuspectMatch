extends Node2D

onready var start_button:Button=$NewGame
onready var howto_button:Button=$HowToPlay
onready var consent:Label=$Consent
onready var game_rules:Label=$GameRules
onready var sound_click:AudioStreamPlayer=$Click
var ads_file = "user://ads.save"
var save_file= "user://score.save"

func _ready():
	#load ad policy
	var ads = File.new()
	if ads.file_exists(ads_file):
		consent.hide()
	else:
		start_button.disabled=true
		start_button.visible=false
		howto_button.disabled=true
		howto_button.visible=false
		
#generate empty save file if game is launched first time
	var last_save_game = File.new()
	if not last_save_game.file_exists(save_file):
		var empty_save_game = File.new()
		var empty_save_data:Dictionary={"highscore":0}
		empty_save_game.open(save_file, File.WRITE)
		empty_save_game.store_line(to_json(empty_save_data))
		empty_save_game.close()	

func _on_NewGame_pressed():
	sound_click.play()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://SourceCode/RoundController.tscn")

func _on_HowToPlay_pressed():
	sound_click.play()
	start_button.disabled=true
	start_button.visible=false
	howto_button.disabled=true
	howto_button.visible=false
	game_rules.show()

func _on_Accept_pressed():
	sound_click.play()
	var ads = File.new()
	ads.open(ads_file, File.WRITE)
	ads.store_var(1)
	ads.close()
	consent.hide()
	start_button.disabled=false
	start_button.visible=true
	howto_button.disabled=false
	howto_button.visible=true


func _on_Back_pressed():
	sound_click.play()
	game_rules.hide()
	start_button.disabled=false
	start_button.visible=true
	howto_button.disabled=false
	howto_button.visible=true
