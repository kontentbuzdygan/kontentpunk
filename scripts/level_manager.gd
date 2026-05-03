extends Node

@export var depth := 4
@export var branches := 3
@export var sort_iterations := 8
@export var weights: Array[float] = [1.0, 1.0, 1.0]

var all_nodes: Array[LevelNode] = []
var root: LevelNode
var tail: LevelNode
var unsorted_tree: Array[Array] = []
var tree: Array[Array] = []
var index: int = 0
var current_player_node: LevelNode

func _ready() -> void:
	init_new_tree()
	current_player_node = root


func init_new_tree() -> void:
	root = create_level_node(0, null)
	tail = create_level_node(depth + 2, null) # null, because we don't know the parent yet

	for i in range(branches):
		root.create_new_path(depth, tail)
	split_tree()
	print("before")
	print(tree)
	unsorted_tree = tree.duplicate_deep()
	sort_parents(1, sort_iterations)
	print("after")
	print(tree)


func get_possible_children_nodes(level: int) -> Array[LevelNode]:
	var children_nodes: Array[LevelNode] = []
	children_nodes.assign(all_nodes.filter(func(node: LevelNode) -> bool: return node.level == level))
	return children_nodes


func create_level_node(level: int, parent: LevelNode) -> LevelNode:
	var new_node := LevelNode.new(index, level, weights, self)
	index += 1

	## Don't allow for repeating parents
	if parent and parent not in new_node.parents:
		new_node.parents.append(parent)
	all_nodes.append(new_node)
	return new_node


func split_tree() -> void:
	for node in all_nodes:
		while tree.size() < node.level + 1:
			tree.append([])
		tree[node.level].append(node)


func sort_parents(level: int, iteration: int) -> void:
	if iteration == 0:
		return
	if level > depth + 2:
		sort_children(level - 1, iteration - 1)
		return
	
	var level_parents: Array[LevelNode] = []
	level_parents.assign(tree[level])
	var ranks: Array[float] = []

	for parent in level_parents:
		var total_rank := 0.0
		for child in parent.children:
			total_rank += tree[level + 1].find(child)
		if parent.children.size():
			total_rank /= parent.children.size()
		else:
			total_rank = tree[level].size() / 2.0
		ranks.append(total_rank)

	ranked_sort(level_parents, ranks)
	sort_parents(level + 1, iteration)


func sort_children(level: int, iteration: int) -> void:
	if iteration == 0:
		return
	if level < 0:
		sort_parents(level + 1, iteration - 1)
		return
	
	var level_children: Array[LevelNode] = []
	level_children.assign(tree[level])
	var ranks: Array[float] = []

	for child in level_children:
		var total_rank := 0.0
		for parent in child.parents:
			total_rank += tree[level - 1].find(parent)
		if child.parents.size():
			total_rank /= child.parents.size()
		else:
			total_rank = tree[level].size() / 2.0
		ranks.append(total_rank)

	tree[level].assign(ranked_sort(level_children, ranks))
	sort_children(level - 1, iteration)


func ranked_sort(nodes: Array[LevelNode], ranks: Array[float]) -> Array[LevelNode]:
	var indices := range(nodes.size())
	indices.sort_custom(func(a: int, b: int) -> bool: return ranks[a] < ranks[b])
	var result: Array[LevelNode] = []
	result.assign(indices.map(func(i: int) -> LevelNode: return nodes[i]))
	return result


func _to_string() -> String:
	var text := ""
	for node in all_nodes:
		text += str(node) + "\n"
	return text


class LevelNode:
	var index: int
	var level: int
	var children: Array[LevelNode] = []
	var parents: Array[LevelNode] = []
	var weights: Array[float]
	var manager: LevelManager
	var button: LevelButton

	func _init(index_: int, level_: int, weights_: Array[float], manager_: LevelManager) -> void:
		index = index_
		level = level_
		weights = weights_
		manager = manager_


	func add_new_node(depth: int, tail: LevelNode) -> void:
		var child: LevelNode = manager.create_level_node(level + 1, self)

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
		
		var possible_children: Array[LevelNode] = manager.get_possible_children_nodes(level + 1)

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


	func _on_button_press() -> void:
		if not SceneManager.level_tree:
			SceneManager.level_tree = manager.tree.duplicate_deep()
		SceneManager.goto_scene("res://levels/main.tscn")


	func _to_string() -> String:
		var children_indexes: String = children.reduce(func(accum: String, child: LevelNode) -> String: return accum + str(child.index) + ", ", "")
		#var parents_indexes: String = parents.reduce(func(accum: String, parent: LevelNode) -> String: return accum + str(parent.index) + ", ", "")

		return "([%d] children: %s)" % [index, children_indexes]


	enum Choice {
		CREATE_NODE = 1,
		CREATE_NODE_AND_EDGE,
		CREATE_EDGE
	}
