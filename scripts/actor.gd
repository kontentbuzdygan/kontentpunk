class_name Actor
extends Node2D

@onready var grid: Grid = find_parent("Grid")
@onready var grid_animation_player: GridAnimationPlayer = find_children("", "GridAnimationPlayer")[0]


func get_current_tile() -> Vector2i:
	return grid.get_node_tile(self)


func move_to(tile: Vector2i) -> bool:
	if grid.get_nodes_on_tile(tile).is_empty():
		CombatState.queue_action(CombatAction.Move.new(self, tile))
		return true

	return false

func execute(action: CombatAction, then: Callable) -> void:
	if action is CombatAction.Move:
		grid_animation_player.move_to(action.target_tile, then)
		return

	assert(false, "invalid action %s for %s" % [action, self])
