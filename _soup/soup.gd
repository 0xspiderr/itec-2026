class_name Soup extends Node2D

@export var starting_time: float = 60.0
@export var soup_time: float
var is_game_over: bool = false
var ingredients: Array[String] = []

@export var item_textures: Dictionary[String, Texture2D]
@export var request_item: String = "":
	set(req):
		request_item = req
		_update_bubble_visuals()

@onready var speech_bubble: Sprite2D = $SpeechBubbleSpawn/SpeechBubble
@onready var bubble_item: Sprite2D = $SpeechBubbleSpawn/SpeechBubble/BubbleItem
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var splash_audio: AudioStreamPlayer2D = $SplashAudio

signal soup_ruined() # game over


const ITEM_TIME_VALUES: Dictionary = {
	"winter berries": 2.0,
	"dried barley": 6.0,
	"mushroom": 8.0,
	"wild leeks": 6.5,
	"turnip": 5.0,
	"meat": 10.0
}

var base_bubble_y: float = 0.0
var hover_time: float = 0.0
const HOVER_AMPLITUDE: float = 8.0
const HOVER_SPEED: float = 2.

func _ready() -> void:
	if progress_bar:
		progress_bar.max_value = starting_time
	base_bubble_y = speech_bubble.position.y
	soup_time = starting_time
	
	if multiplayer.is_server():
		_pick_new_request()


func _process(delta: float) -> void:
	_hover_bubble()
	_update_progress_bar()
	if not multiplayer.is_server() or is_game_over:
		return
	
	soup_time -= delta
	
	if soup_time <= 0.0:
		soup_time = 0.0
		is_game_over = true
		soup_ruined.emit()

func server_receive_ingredient(_player: RatController, item_name: String) -> void:
	if not multiplayer.is_server() or is_game_over: 
		return
	
	ingredients.append(item_name)
	
	var time_added = ITEM_TIME_VALUES.get(item_name, 5.0)
	if item_name == request_item:
		print("bonus time")
		soup_time += time_added + 5.0 # give a 5 second bonus for the right item
		request_item = ""
		
		await get_tree().create_timer(0.5).timeout
		_pick_new_request() # pick the next item
	else:
		soup_time += time_added # just normal time if it's the wrong item
		request_item = ""
		
		await get_tree().create_timer(0.5).timeout
		_pick_new_request()
	
	print("soup received: ", item_name, " added: ", time_added, "s total: ", soup_time, "s")
	
	_sync_soup_data.rpc(ingredients)


@rpc("authority", "call_local", "reliable")
func _sync_soup_data(synced_ingredients: Array) -> void:
	ingredients = synced_ingredients
	splash_audio.play()


func _pick_new_request() -> void:
	var item_names = ITEM_TIME_VALUES.keys()
	var random_index = randi() % item_names.size()
	request_item = item_names[random_index]


func _update_bubble_visuals() -> void:
	# hide the bubble if there is no request or the game is over
	if request_item == "":
		var tween = create_tween()
		tween.tween_property(speech_bubble, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	else:
		if item_textures.has(request_item):
			bubble_item.texture = item_textures[request_item]
		speech_bubble.show()
		var tween = create_tween()
		tween.tween_property(speech_bubble, "scale", Vector2(1.0, 1.0), 0.3)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)


func _hover_bubble() -> void:
	hover_time += get_process_delta_time()
	var y_offset = sin(hover_time * HOVER_SPEED) * HOVER_AMPLITUDE
	speech_bubble.position.y = base_bubble_y + y_offset


func _update_progress_bar() -> void:
	if progress_bar:
		progress_bar.value = soup_time


func server_receive_log() -> void:
	if not multiplayer.is_server() or is_game_over: 
		return
	
	var massive_time_boost = 20.0
	soup_time += massive_time_boost
	
	print("buturuga pe foc ", massive_time_boost, "s total: ", soup_time, "s")
	_sync_soup_data.rpc(ingredients)

func server_receive_cat_explosion() -> void:
	if not multiplayer.is_server() or is_game_over: 
		return
	
	var penalty = 15.0
	soup_time -= penalty
	if soup_time < 0.0:
		soup_time = 0.0
		
	print("cat exploded: ", penalty, "s remaining: ", soup_time, "s")
