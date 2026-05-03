class_name LevelTree
extends Control

@export var depth := 4
@export var branches := 3
@export var sort_iterations := 8
@export var weights: Array[float] = [1.0, 1.0, 1.0]

var all_nodes: Array[LevelNode] = []
var root: LevelNode
var tail: LevelNode
var unsorted_tree: Array[Array] = []
var tree: Array[Array] = []

func _ready() -> void:
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
	draw_graph(tree)


func get_possible_children_nodes(level: int) -> Array[LevelNode]:
	var children_nodes: Array[LevelNode] = []
	children_nodes.assign(all_nodes.filter(func(node: LevelNode) -> bool: return node.level == level))
	return children_nodes


func create_level_node(level: int, parent: LevelNode) -> LevelNode:
	var new_node := LevelNode.new(get_child_count(), level, weights)

	## Don't allow for repeating parents
	if parent and parent not in new_node.parents:
		new_node.parents.append(parent)
	all_nodes.append(new_node)
	add_child(new_node)
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


func draw_graph(tree_: Array[Array]) -> void:
	var resolution := get_window().size
	var y_offset := 40
	for level in tree_:
		for node_index in range(level.size()):
			var node := level[node_index] as LevelNode
			var x := (resolution[0] * (node_index + 1)) / (level.size() + 1)
			var y := resolution[1] - (node.level + 1) * y_offset
			node.position.x = x
			node.position.y = y

			for parent in node.parents:
				var line := Line2D.new()
				line.width = 1
				line.add_point(Vector2(node.position.x + node.size[0] / 2, node.position.y + node.size[1] / 2))
				line.add_point(Vector2(parent.position.x + parent.size[0] / 2, parent.position.y + parent.size[1] / 2))
				add_child(line)


func _on_check_button_toggled(toggled_on: bool) -> void:
	print("toggled")
	for child in get_children():
		if is_instance_of(child, Line2D):
			remove_child(child)
			child.queue_free()

	if toggled_on:
		draw_graph(tree)
	else:
		draw_graph(unsorted_tree)
