extends Control

@onready var start_button: Button = $Menu/StartButton
@onready var options_button: Button = $Menu/OptionsButton
@onready var full_screen: CheckBox = $Options/VBoxContainer/Video/Checks/FullScreen

@onready var options: Control = $Options
@onready var menu: VBoxContainer = $Menu

@onready var previous_window = DisplayServer.window_get_mode()
@onready var current_window = DisplayServer.window_get_mode()

@onready var background_color: ColorRect = $BackgroundColor
@onready var blur_background: ColorRect = $BlurBackground
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var checkForKeyPress = false;
var current_scene 
var isMenuOpen

func _ready() -> void:
	current_scene = menu
	start_button.grab_focus()

func _process(delta: float) -> void:
	_game_started()
	#_input(InputEvent)

var dash_input_event
func disable_dash():
	dash_input_event = InputMap.action_get_events("dash")
	InputMap.action_erase_events("dash")
func renable_dash():
	for input_event in dash_input_event:
		InputMap.action_add_event("dash", input_event)
	
func _check_inputs():
	if (Input.is_action_just_pressed("ui_menu_back") or Input.is_action_just_pressed("ui_pause")) and current_scene == options:
		start_button.grab_focus()
		_show_and_hide(menu, options)
	#start_button.grab_focus()
		#_show_and_hide(menu, options)

func _game_started():
	if(Global.gameIsStarted == true):
		start_button.text = "Resume"
		#start_button.visible = false
		blur_background.visible = true
		background_color.visible = false
		if (Input.is_action_just_pressed("ui_menu_back") and isMenuOpen == true) or Input.is_action_just_pressed("ui_pause"):
			if current_scene == menu:
				_toggleMenu()
			else:
				_show_and_hide(menu, options)
				start_button.grab_focus()
	else:
		_check_inputs()
		
func _toggleMenu():
	if visible == false:
		visible = true
		animation_player.play("Pause")
		isMenuOpen = true
		disable_dash()
	else:
		animation_player.play("Unpause")
		visible = false
		isMenuOpen = false
		renable_dash()
	_show_and_hide(menu, options)
	start_button.grab_focus()
	get_tree().paused = visible

#func _input(event):
	#if event is InputEventMouseMotion:
		#for button in menu.get_children(): 
			#button.release_focus()
		#checkForKeyPress = true
		#
	#if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		#if checkForKeyPress == true:
			#start_button.grab_focus()
			#checkForKeyPress = false

func _on_start_button_pressed() -> void:
	if(Global.gameIsStarted == true):
		_toggleMenu()
	else:
		start_button.text = "Resume"
		Global.gameIsStarted = true
		background_color.visible = false
		get_tree().change_scene_to_file("res://IntroScene/IntroScene.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	full_screen.grab_focus()
	_show_and_hide(options, menu)
	
func _on_back_pressed() -> void:
	start_button.grab_focus()
	_show_and_hide(menu, options)

func _show_and_hide(first,second):
	current_scene = first
	first.show()
	second.hide()

func _on_borderless_toggled(toggled_on: bool) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_full_screen_toggled(toggled_on: bool) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_v_sync_toggled(toggled_on: bool) -> void:
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

func _on_master_value_changed(value: float) -> void:
	adjust_volume("Master", value)

func _on_music_value_changed(value: float) -> void:
	adjust_volume("Music", value)

func _on_sound_effects_value_changed(value: float) -> void:
	adjust_volume("SFX", value)

#func volume(bus_index, value):
	#AudioServer.set_bus_volume_db(bus_index, value)

# Convert a linear scale value to decibels for the audio bus volume.
func adjust_volume(bus_name: String, linear_value: float):
	var db_value = linear2db(linear_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_value)

# Convert linear volume to decibels. 0 is silent, 100 is full volume.
func linear2db(linear_value: float) -> float:
	if linear_value == 0:
		return -80.0 # Minimum volume level in decibels.
	else:
		var t = linear_value / 100.0
		return 20.0 * log(t) / log(10.0) # Convert linear value to decibels.


