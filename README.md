# InverseKinematics
Simple way of creating something that looks like IK joints.

<h1>How to Create Varying Joint Lengths</h1>
In the InverseKinematics scene, you can enable creating its own individual joints but they'll all have the same length.
If you want varying joint sizes, disable "auto_create_joints" and add IKJoint scenes as a child to the InverseKinematics scene.
The order of the children is the order of joints and the positions in the editor become the joint lengths.
