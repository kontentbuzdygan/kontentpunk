class_name Actor
extends Node2D

@onready var grid: Grid = find_parent("Grid")
@onready var grid_animation_player: GridAnimationPlayer = find_children("", "GridAnimationPlayer")[0]


func move_to(tile: Vector2i) -> void:
	if grid.get_nodes_on_tile(tile).is_empty():
		State.queue_combat_action(CombatAction.Move.new(self, tile))


func execute(action: CombatAction, then: Callable) -> void:
	if action is CombatAction.Move:
		grid_animation_player.move_to(action.target_tile, then)
