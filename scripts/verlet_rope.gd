class_name VerletRope
extends Node2D

@export var velvet_node_scene: PackedScene
@export var length := 50
@export var nodes := 3

@onready var nodes_container: Node2D = $Nodes
@onready var lines_container: Node2D = $Lines

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(nodes):
		print("spawning node")
		var instance: VerletNode = velvet_node_scene.instantiate()
		instance.position.x += 100
		instance.position.y += length * i
		nodes_container.add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	for child in lines_container.get_children():
		lines_container.remove_child(child)
		child.queue_free()

	for child_index in range(nodes_container.get_children().size() - 1):
		var line2d: Line2D = Line2D.new()
		line2d.default_color = 0xd32836ff
		line2d.width = 2

		var parent_velvet: VerletNode = nodes_container.get_children()[child_index]
		var child_velvet: VerletNode = nodes_container.get_children()[child_index + 1]
		line2d.add_point(parent_velvet.position)
		line2d.add_point(child_velvet.position)
		lines_container.add_child(line2d)

	for i in range(5):
		for node_index in range(nodes_container.get_children().size() - 1):
			satisfy_distance(nodes_container.get_children()[node_index], nodes_container.get_children()[node_index + 1])
			calculate_rotation(nodes_container.get_children()[node_index], nodes_container.get_children()[node_index + 1])


func satisfy_distance(node1: VerletNode, node2: VerletNode) -> void:
	var d := node2.position - node1.position
	var distance: float = sqrt(d.x * d.x + d.y * d.y)

	var correction := (distance - length) / distance

	var halfC: Vector2 = d * correction * 0.5

	if not node1.pinned:
		node1.position += halfC
	if not node2.pinned:
		node2.position -= halfC

func calculate_rotation(node1: VerletNode, node2: VerletNode) -> void:
	node1.rotation = atan2(node2.position.y - node1.position.y, node2.position.x - node1.position.x)
	node2.rotation = atan2(node1.position.y - node2.position.y, node1.position.x - node2.position.x)
