class_name LootContainer
extends HFlowContainer

@export var item_holder_scene: PackedScene

var current_lootbag: Lootbag:
	get():
		return current_lootbag
	set(value):
		clear_ui()

		current_lootbag = value
		for item in current_lootbag.loot:
			print("Creating item holder")
			var instance: ItemHolder = item_holder_scene.instantiate()
			instance.item = item
			self.add_child(instance)


func _ready() -> void:
	if not item_holder_scene:
		push_error("ItemHolder missing from LootContainer")


func clear_ui():
	var children = self.get_children()

	for child in children:
		self.remove_child(child)
		child.queue_free()


func _process(_delta: float) -> void:
	if not CombatState.get_instance().is_in_progress():
		self.visible = true
	else:
		self.visible = false


func on_lootbag_update(item: Item):
	if not current_lootbag:
		return

	var loot = current_lootbag.loot
	if item in loot:
		loot.remove_at(loot.find(item))

	# Remove lootbag with no loot from the scene
	if loot.size() == 0:
		current_lootbag.queue_free()
