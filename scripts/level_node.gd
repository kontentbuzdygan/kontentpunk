class_name LevelNode
extends Button

var index: int
var level: int
var children: Array[LevelNode] = []
var parents: Array[LevelNode] = []
var weights: Array[float]

@onready var manager: LevelTree = get_parent()

func _init(index_: int, level_: int, weights_: Array[float]) -> void:
	index = index_
	level = level_
	weights = weights_
	z_index = 999
	text = str(index)


func add_new_node(depth: int, tail: LevelNode) -> void:
	var child := manager.create_level_node(level + 1, self)

	## Don't allow for repeating children
	if child not in children:
		children.append(child)
	child.create_new_path(depth, tail)


func add_new_edge(node: LevelNode) -> void:
	if node not in children:
		children.append(node)
	if self not in node.parents:
		node.parents.append(self)


func create_new_path(depth: int, tail: LevelNode) -> void:
	if level > depth:
		add_new_edge(tail)
		return
	
	## If we are on a node that already was used to make a path,
	## add new node to create more variety
	if children:
		add_new_node(depth, tail)
		return
	
	var possible_children := manager.get_possible_children_nodes(level + 1)

	## If no children, then just create new node
	if not possible_children.size():
		add_new_node(depth, tail)
		return
	
	var rng := RandomNumberGenerator.new()
	var choice: Choice = Choice.values()[rng.rand_weighted(weights)]
	match choice:
		Choice.CREATE_NODE:
			add_new_node(depth, tail)
		Choice.CREATE_NODE_AND_EDGE:
			add_new_edge(possible_children.pick_random())
			add_new_node(depth, tail)
		Choice.CREATE_EDGE:
			var child: LevelNode = possible_children.pick_random()
			add_new_edge(child)
			child.create_new_path(depth, tail)


func _to_string() -> String:
	var children_indexes: String = children.reduce(func(accum: String, child: LevelNode) -> String: return accum + str(child.index) + ", ", "")
	#var parents_indexes: String = parents.reduce(func(accum: String, parent: LevelNode) -> String: return accum + str(parent.index) + ", ", "")

	return "([%d] children: %s)" % [index, children_indexes]


enum Choice {
	CREATE_NODE = 1,
	CREATE_NODE_AND_EDGE,
	CREATE_EDGE
}
