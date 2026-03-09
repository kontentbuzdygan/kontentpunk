@tool
class_name ItemResource
extends Resource

enum ITEM_TYPE { NONE, HEAD, HEART, ARM, SPINE, LEG }

@export var name: String
@export var icon: Texture2D
@export var item_type: ITEM_TYPE
@export var ability: Ability
@export var cost_per_turn: int
@export var stamina: int
@export var cooldown: int