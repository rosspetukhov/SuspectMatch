extends Node2D

#external nodes
onready var character:Node2D=$Character
onready var clues:Node2D=$Clues
onready var time_label:Label=$TimeScore
onready var time_title_label:Label=$TimeTitle
onready var score_label:Label=$Score
onready var highscore_label:Label=$Highscore
onready var scoretitle_label:Label=$ScoreTitle
onready var highscoretitle_label:Label=$HighscoreTitle
onready var result_message:Label=$ResultMessage
onready var timer_swipe:Timer=$TimerSwipe
onready var timer_result:Timer=$TimerResult
onready var timer_lose:Timer=$TimerLose
onready var timer_dead:Timer=$TimerDeadline
onready var tween:Tween=$Tween
onready var screen:ColorRect=$Screen
onready var background:ColorRect=$Background
onready var anim:AnimationPlayer=$AnimationPlayer
onready var sound_win:AudioStreamPlayer=$Win
onready var sound_lose:AudioStreamPlayer=$Lose
onready var sound_click:AudioStreamPlayer=$Click
onready var sound_array:Array=[$S1,$S2,$S3,$S4,$S5,$S6,$S7]
onready var admob:Node=$Admob

#save data
var save_file= "user://suspectroomscore.save"

#count of characteristics
const count_of_char:int=6
#variations of each characteristics
const num_of_var:int=4
#position of a criminal
var criminal_id:int
#character on screen
var photo_id:int=0
#array with characteristics for all suspects
var suspects_array:Array
#suspects count
var suspects_count:int
#coordinates of a swipe at the start of the swipe:
var swipe_start_pos:Vector2
#score values
var score:int
var highscore:int
#control user input - you dont want to submit results twice in short period of time
var input_allowed:bool=false
#timer value
var timer_value:int
var timer_active:bool

func _ready():
	#have random values
	randomize()	
	#set score
	highscore=load_game()
	score=0
	new_game()
	input_allowed=true
	
#generate new suspects
func new_game():
	suspects_array=[]
	photo_id=0
	score_label.text=str(score)
	highscore_label.text=str(highscore)
	#array with criminal characteristics
# warning-ignore:unassigned_variable
	var criminal_array:Array
	#count of suspects
# warning-ignore:narrowing_conversion
	suspects_count=floor(rand_range(4,7))
	#set position of criminal
# warning-ignore:narrowing_conversion
	criminal_id=floor(rand_range(0,suspects_count))
	#step count for while loop
	var step:int=0
	#clues array
# warning-ignore:unused_variable
	var clues_array:Array
	#populate array of characterics for a criminal
	for _i in range(count_of_char):
		var rand=floor(rand_range(0,num_of_var))
		criminal_array.append(rand)
	#generate all suspects characterstics and put in a suspect_array
	while step!=suspects_count:
		#add criminal data
		if criminal_id==step:
			suspects_array.append(criminal_array)
			step+=1
		#add innocents data
		else:
			#array with innocents characteristics
			var innocents_array:Array=[]
			for i in range(count_of_char):
				var inn_char:int
				var rand=floor(rand_range(0,4))
				var add:int=1
				if rand!=0:
					add=0
				if criminal_array[i]+add>=num_of_var:
					inn_char=criminal_array[i]+add-num_of_var
				else:
					inn_char=criminal_array[i]+add
				innocents_array.append(inn_char)
			#check if innocent is exactly the same as criminal
			var redo_needed:int=0
			for i in range(count_of_char):
				if innocents_array[i]==criminal_array[i]:
					redo_needed+=1
			if redo_needed!=count_of_char:
				suspects_array.append(innocents_array)
				step+=1
			else:
				print("reshuffle")
	
	#create clues info
	clues.set_clues(criminal_array, suspects_array)
# warning-ignore:return_value_discarded
	tween.interpolate_property(clues, "position",
	clues.get_position(), Vector2(420,1300), 0.5,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
# warning-ignore:return_value_discarded
	tween.start()
	yield(tween,"tween_all_completed")
	anim.play("idle")
	
	#start the game with first photo shown
	print_photo(true)
	print("criminal",criminal_id+1, "/", suspects_count)
	
	#timer details
	if score<3:
		timer_value=suspects_count*6
	elif score<6:
		timer_value=suspects_count*5
	elif score<9:
		timer_value=suspects_count*4
	elif score<12:
		timer_value=suspects_count*3
	else:
		timer_value=suspects_count*2
		
	timer_active=true
	timer_dead.start()
	time_label.text=str(timer_value)+" s"
	
	#ads
	admob.load_banner()
# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_on_resize")
	
#print new photo and make sound. dont make sound if loading
func print_photo(initial_load=false):
	if !initial_load:
		sound_array[photo_id].play()
	character.set_character(suspects_array[photo_id],photo_id)
	
#player moves 1/4
func _input(event):
	if not event is InputEventScreenTouch or input_allowed==false:
		return
	if event.pressed:
		start_detection(event.position)
	elif not timer_swipe.is_stopped():
		end_detection(event.position)
#player moves 2/4
func start_detection(position):
	swipe_start_pos=position
	timer_swipe.start()
#player moves 3/4	
func end_detection(position):
	timer_swipe.stop()
	var direction=(position-swipe_start_pos).normalized()
	if abs(direction.x)+abs(direction.y)>=1.3:
		return
	if abs(direction.x)>abs(direction.y):
		#swipe to change photo
		if direction.x<0:
			if photo_id!=suspects_count-1:
				photo_id+=1
			else:
				photo_id=0
			print_photo()
		#swipe to check
		if direction.x>0:
			check_win("swipe")

#check if users guess was correct
func check_win(type):
	result_message.visible=true
	character.visible=false
	time_label.visible=false
	time_title_label.visible=false
	score_label.visible=false
	scoretitle_label.visible=false
	highscore_label.visible=false
	highscoretitle_label.visible=false
	screen.color=Color8(0,0,0,255)
	timer_active=false
	input_allowed=false
	anim.stop()
	#win
	if photo_id==criminal_id:
		result_message.text="Well done, you detained a criminal!"
		sound_win.play()
		score+=1
		background.color=Color8(67,170,139,255)
		result_message.set("custom_colors/font_color", Color8(67,170,139,255))
		if score>highscore:
			highscore=score
			save_game()
	#lose
	else:	
		sound_lose.play()
		if type=="swipe":
			clues.highlight_difference(photo_id)
			result_message.text="Boo! You detained an innocent person!"
		else:
			result_message.text="Boo! You ran out of time!"
		background.color=Color8(249,65,68,255)
		result_message.set("custom_colors/font_color", Color8(249,65,68,255))
		timer_lose.start()
		yield(timer_lose,"timeout")
		score=0
	#new game	
# warning-ignore:return_value_discarded
	tween.interpolate_property(clues, "position",
	clues.get_position(), Vector2(0,2500), 0.5,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
# warning-ignore:return_value_discarded
	tween.start()
	yield(tween,"tween_all_completed")
	new_game()
	timer_result.start()
	
#save the game. update highscore if score is higher than last saved highscore
func save_game():
	var save_game=File.new()
	var save_data:Dictionary={"highscore":highscore}
	save_game.open(save_file,File.WRITE)
	save_game.store_line(to_json(save_data))
	save_game.close()
		
func load_game():
	var save_game=File.new()
	var save_data:Dictionary
	if not save_game.file_exists(save_file):
		return 0
	else:
		save_game.open(save_file,File.READ)
		save_data=parse_json(save_game.get_line())
		save_game.close()
		return save_data["highscore"]

func _on_TimerResult_timeout():
	print("timeout")
	input_allowed=true
	result_message.visible=false
	character.visible=true
	time_label.visible=true
	time_title_label.visible=true
	score_label.visible=true
	scoretitle_label.visible=true
	highscore_label.visible=true
	highscoretitle_label.visible=true
	screen.color=Color8(34,185,195,255)
	background.color=Color8(0,0,0,255)

func _on_TimerDeadline_timeout():
	if timer_active:
		timer_dead.start()
		timer_value-=1
		if timer_value==0:
			check_win("timer")
			time_label.text=str(timer_value)+" s"
		if timer_value>0:
			time_label.text=str(timer_value)+" s"

func _on_Menu_pressed():
	sound_click.play()
	anim.stop()
	# warning-ignore:return_value_discarded
	tween.interpolate_property(clues, "position",
	clues.get_position(), Vector2(0,2500), 0.5,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
# warning-ignore:return_value_discarded
	tween.start()
	yield(tween,"tween_all_completed")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://SourceCode/TitleScreen.tscn")
