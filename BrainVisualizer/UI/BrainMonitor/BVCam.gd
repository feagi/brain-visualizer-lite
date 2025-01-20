# Copyright 2016-2022 The FEAGI Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

extends Camera3D
class_name BVCam

const CAMERA_TURN_SPEED = 200
const CAMERA_TELEPORT_FROM_DISTANCE: float = 50.0
const CAMERA_ANIMATION_NAME: StringName = "CAMERA_PATH"
const CAMERA_LIBRARY_NAME: StringName = "CAMERA_ANIM_LIB"
const ANIMATION_PLAYER_NAME: NodePath = "AnimationPlayer"
const ANIMATION_TIMER_NAME: NodePath = "AnimTimer"

@export var camera_pan_button: MouseButton = MOUSE_BUTTON_LEFT
@export var camera_turn_button: MouseButton = MOUSE_BUTTON_RIGHT
@export var camera_movement_speed: float =  2.0
@export var camera_pan_speed: float = 0.1
@export var camera_rotation_speed: float = 0.001
# Are these exports used?
@export var forward_action = "ui_up"
@export var backward_action = "ui_down"
@export var left_action = "ui_left"
@export var right_action = "ui_right"
@export var spacebar = "ui_select"
@export var reset = "reset"
@export var fast_camera_button: Key = Key.KEY_SHIFT
@export var fast_camera_speed_multiplier: float = 3.0

var is_playing_animation: bool = false

var _is_user_currently_focusing_camera: bool = false
var _initial_position: Vector3
var _initial_euler_rotation: Vector3

func _ready() -> void:
	var bv_background: FullScreenControl = get_node("../BV_Background")
	bv_background.click_event.connect(_scroll_movment_and_toggle_camera_focus)
	bv_background.pan_event.connect(_touch_pan_gesture)
	bv_background.keyboard_event.connect(_keyboard_camera_movement)
	_initial_position = position
	_initial_euler_rotation = rotation_degrees

# Guard Clauses!
func _input(event: InputEvent):
	
	if is_playing_animation:
		return
	
	# Feagi Interaction doesnt require camera control
	if event is InputEventKey:
		if get_node("../BV_Background").has_focus():
			_FEAGI_data_interaction(event)
	
	if !_is_user_currently_focusing_camera:
		return
	
	# If user starts / stops keyboard press
	if event is InputEventKey:
		_keyboard_camera_movement(event)

	# If user is moving the mouse
	if event is  InputEventMouseMotion:
		_mouse_motion(event)

## Resets Cameras position and rotation to starting state
func reset_camera() -> void:
	teleport_to(_initial_position, _initial_euler_rotation)

func teleport_to(new_position: Vector3, new_euler_rotation: Vector3) -> void:
	position = new_position
	rotation_degrees = new_euler_rotation

func point_camera_at(position_to_look_at: Vector3) -> void:
	look_at(position_to_look_at, Vector3.UP)

func teleport_to_look_at_without_changing_angle(position_to_point_at: Vector3) -> void:
	position = _get_endpoint_position(position_to_point_at, CAMERA_TELEPORT_FROM_DISTANCE)


func play_animation(animation: Animation) -> void:	
	if is_playing_animation:
		return
	
	# Create Animation Player
	var animation_player: AnimationPlayer
	if get_node_or_null(ANIMATION_PLAYER_NAME) != null:
		kill_animation() 
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	animation_player.name = str(ANIMATION_PLAYER_NAME)
	animation_player.root_node = ("/root")
	
	# Confirm animation Library
	if !animation_player.has_animation_library(CAMERA_LIBRARY_NAME):
		animation_player.add_animation_library(CAMERA_LIBRARY_NAME, AnimationLibrary.new())
	
	# Add animation to library
	var animation_library: AnimationLibrary = animation_player.get_animation_library(CAMERA_LIBRARY_NAME)
	if animation_library.has_animation(CAMERA_ANIMATION_NAME):
		animation_library.remove_animation(CAMERA_ANIMATION_NAME)
	animation_library.add_animation(CAMERA_ANIMATION_NAME, animation)
	is_playing_animation = true
	animation_player.play(CAMERA_LIBRARY_NAME + "/" + CAMERA_ANIMATION_NAME)
	
	# add ending timer
	await get_tree().create_timer(animation.length).timeout
	kill_animation()
	

func kill_animation() -> void:
	is_playing_animation = false
	if get_node_or_null(ANIMATION_PLAYER_NAME) == null:
		return
	var animation_player: AnimationPlayer = $AnimationPlayer
	animation_player.stop()
	animation_player.queue_free()
	
	
	

func _scroll_movment_and_toggle_camera_focus(event: InputEventMouseButton):

	# This section is here to allow for scroll movement without having to focus the camera
	match event.button_index:
		MOUSE_BUTTON_WHEEL_DOWN:
			translate(Vector3(0,0,camera_movement_speed))
		MOUSE_BUTTON_WHEEL_UP:
			translate(Vector3(0,0,-camera_movement_speed))

	if (event.button_index != camera_pan_button) and (event.button_index != camera_turn_button):
		return
	_is_user_currently_focusing_camera = event.is_pressed()


# The camera itself should probably not be the thing sending the websocket requests. TODO move to seperate once we have the free time
func _FEAGI_data_interaction(_keyboard_event: InputEventKey) -> void:
	if Input.is_action_just_pressed("spacebar"): 
		print(Godot_list.godot_list)
		FeagiCore.network.websocket_API.websocket_send(str(Godot_list.godot_list))
		return
	if Input.is_action_just_pressed("del"): 
		for key in Godot_list.godot_list["data"]["direct_stimulation"]:
			Godot_list.godot_list["data"]["direct_stimulation"][key] = []
		return
	if Input.is_action_just_pressed("reset_camera"):
		
		reset_camera()



# TODO fix the awkward initial delay, we need to move this to a fixed process thread
func _keyboard_camera_movement(_keyboard_event: InputEventKey) -> void:
	var dir: Vector3 = Vector3(0,0,0)

	if Input.is_key_pressed(KEY_R):
		reset_camera()
		return
	if Input.is_action_pressed("forward"):
		dir += Vector3(0,0,-1)
	if Input.is_action_pressed("backward"):
		dir += Vector3(0,0,1)
	if Input.is_action_pressed("left"):
		dir += Vector3(-1,0,0)
	if Input.is_action_pressed("right"):
		dir += Vector3(1,0,0)
	
	var speed: float = camera_movement_speed
	if Input.is_key_pressed(fast_camera_button):
		speed *= fast_camera_speed_multiplier
	
	dir = dir.normalized() * speed
	translate(dir)


# TODO couldnt panning happen in 2 dimensions? not just y? This should be discussed so we are all in agreeement
## Touch screen panning
func _touch_pan_gesture(event: InputEventPanGesture) -> void:
	var direction = Vector3(0,0,event.delta.y).normalized()
	translate(direction)

## Mouse moving controls
func _mouse_motion(event: InputEventMouseMotion) -> void:


	if Input.is_mouse_button_pressed(camera_turn_button):
		rotation.x += event.relative.y * -camera_rotation_speed
		rotation.y += event.relative.x * -camera_rotation_speed
		return
	
	if Input.is_mouse_button_pressed(camera_pan_button):
		var move: Vector3 = Vector3(event.relative.x * -camera_pan_speed, event.relative.y * camera_pan_speed, 0)
		translate(move)

func _get_endpoint_position(start_position: Vector3, linear_distance: float) -> Vector3:
	var offset: Vector3 = (quaternion * (Vector3.FORWARD)) * -linear_distance
	return start_position + offset
	
