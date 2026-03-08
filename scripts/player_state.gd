extends Node

var _resources: Dictionary[PlayerResource.Type, PlayerResource] = {
	PlayerResource.Type.HEALTH: PlayerResource.new(5),
	PlayerResource.Type.MANA: PlayerResource.new(5),
}

func get_resource(type: PlayerResource.Type) -> PlayerResource:
	return _resources[type]
