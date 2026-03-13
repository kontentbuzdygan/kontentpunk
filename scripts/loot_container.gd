class_name LootContainer
extends PanelContainer

@export var item_holder_scene: PackedScene
@onready var item_slot_container = %ItemSlotContainer

var current_lootbag: Lootbag:
	get():
		return current_lootbag
	set(value):
		current_lootbag = value
		clear_ui()

		if not value:
			return

		for item in current_lootbag.loot:
			print("Creating item holder")
			var instance: ItemHolder = item_holder_scene.instantiate()
			instance.item = item
			item_slot_container.add_child(instance)


func _ready() -> void:
	if not item_holder_scene:
		push_error("ItemHolder missing from LootContainer")


func clear_ui():
	self.visible = false
	var children = item_slot_container.get_children()

	for child in children:
		item_slot_container.remove_child(child)
		child.queue_free()


func _process(_delta: float) -> void:
	if not CombatState.get_instance().is_in_progress() and current_lootbag:
		self.visible = true
	else:
		self.visible = false


func on_take_item(item: Item):
	if not current_lootbag:
		return

	var loot = current_lootbag.loot
	if item in loot:
		loot.remove_at(loot.find(item))

	# Remove lootbag with no loot from the scene
	if loot.size() == 0:
		current_lootbag.queue_free()
		current_lootbag = null
