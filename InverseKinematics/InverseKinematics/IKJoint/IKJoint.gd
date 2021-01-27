tool
extends Node2D

class_name IKJoint

#IK variables
var prev_joint
export(bool) var enabled = true

#Joint Length
export(float) var joint_length = 48.0 setget set_joint_length

#Textures
export(bool) var disable_joint_rotation = false
export(float) var disabled_joint_rotation_offset = 0
export(float) var joint_rotation_offset = 180
export(Texture) var joint_texture = preload("res://Textures/Joint0000.png")
export(Texture) var spacer_texture = preload("res://Textures/Joint0001.png")
export(Texture) var spacer_end_texture = preload("res://Textures/Joint0002.png")


func _ready() -> void:
	#Update
	set_textures()
	
	#Set Length
	set_joint_length(joint_length, true)


func set_textures() -> void:
	#Set textures
	$Joint.texture = joint_texture
	$JointSpacer/Spacer.texture = spacer_texture
	$JointSpacer/End.texture = spacer_end_texture


func set_joint_length(val, resize: bool = false) -> void:
	#Resize Joint Size
	joint_length = val
	
	#Editor
	if Engine.editor_hint || resize:
		$JointSpacer/Spacer.rect_size.x = joint_length - 16
		$JointSpacer/End.rect_position.x = joint_length - 16
	
		#Resize Joint Spacer
		$JointSpacer.rect_size.x = joint_length


func _on_JointSpacer_resized():
	#Resize Joint Size
	
	#Editor
	if Engine.editor_hint:
		joint_length = $JointSpacer.rect_size.x
		$JointSpacer/Spacer.rect_size.x = joint_length - 16
		$JointSpacer/End.rect_position.x = joint_length - 16


func _process(delta):
	#Stop Sprite Rotating
	if disable_joint_rotation:
		$Joint.global_rotation = deg2rad(disabled_joint_rotation_offset)
	else:
		if prev_joint != null:
			$Joint.global_rotation = (prev_joint.global_position - global_position).angle() + deg2rad(joint_rotation_offset)

