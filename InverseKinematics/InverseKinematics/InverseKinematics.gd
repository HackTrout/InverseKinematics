extends Node2D

#Joint Variables
export(bool) var follow_mouse = false
export(NodePath) var target_point_path
export(float) var speed = 5.0

export(bool) var auto_create_joints = true
export(int) var joint_amount = 3
export(float) var joint_length = 48.0

var previous_target_point := Vector2.ZERO
var current_target_point := Vector2.ZERO

var joints = []
var end_joint = null

#Textures
export(Texture) var end_texture


func _ready():
	#Create Joints
	if auto_create_joints:
		create_joints()
	else:
		grab_joints()
	
	#Update End texture
	if end_texture != null:
		end_joint.get_node("Joint").texture = end_texture
	
	#Update Targets
	current_target_point = end_joint.global_position
	previous_target_point = current_target_point


func create_joints() -> void:
	#Create Joints
	var prev_joint = self
	for i in range(joint_amount):
		#Create Joint
		var joint = load("res://InverseKinematics/IKJoint/IKJoint.tscn").instance()
		add_child(joint)
		
		#Append to Array
		joints.append(joint)
		
		#Reposition
		joint.global_position = global_position + (Vector2.RIGHT * ((joint_length * i) * scale.x))
		
		#Set Joint Length
		joint.joint_length = joint_length
		
		#Resize Joint's Arm
		if i + 1 == joint_amount:
			joint.get_node("JointSpacer").visible = false
			end_joint = joint
		else:
			joint.get_node("JointSpacer").rect_size.x = joint_length
		
		#Update Target Joint for Prev Joint
		joint.prev_joint = prev_joint
		
		#Update Prev Joint
		prev_joint = joint


func grab_joints() -> void:
	#Loop through children and set joints
	var prev_joint = self
	for child in get_children():
		if child.is_in_group("IKJoint"):
			#Set Joint and Prev joint
			if prev_joint != self:
				var length = floor((child.global_position - prev_joint.global_position).length() / scale.x)
				prev_joint.set_joint_length(length, true)
			child.prev_joint = prev_joint
			
			#Update Prev Joint
			prev_joint = child
			
			#Append to Array
			joints.append(child)
	
	#Get Last Joint
	end_joint = joints[joints.size() - 1]
	end_joint.get_node("JointSpacer").visible = false
	
	#Set Joint Amount
	joint_amount = joints.size()


func update_target_point(pos: Vector2 = Vector2.ONE) -> void:
	#Override
	if pos != Vector2.ONE:
		current_target_point = pos
		return
	
	#Update Current
	if follow_mouse:
		current_target_point = get_global_mouse_position()
	else:
		current_target_point = get_node(target_point_path).global_position


func _process(delta):
	#Update Target if Following Mouse
	if follow_mouse: update_target_point()
	
	#Auto Turn
	var joint = end_joint
	var target_joint = end_joint
	while joint != self:
		#Get Target Position
		if joint.enabled == true:
			var target_pos
			if joint == end_joint:
				#Last Joint
				previous_target_point = lerp(previous_target_point, current_target_point, delta * speed)
				target_pos = previous_target_point
				
				#Adjust its Position
				var dif = (target_pos - joint.global_position)
				var angle = dif.angle()
				joint.global_rotation = angle
				joint.global_position = target_pos
			else:
				#Other Joints
				target_pos = target_joint.global_position
				
				#Adjust its Position
				var dif = (target_pos - joint.global_position)
				var angle = dif.angle()
				joint.global_rotation = angle
				joint.global_position = target_pos - (dif.normalized() * (joint.joint_length * scale.x))
		
		#Get Next Joint
		target_joint = joint
		joint = joint.prev_joint
	
	#Reposition Chain
	var offset = global_position - joints[0].global_position
	for joint in joints:
		joint.global_position += offset
