extends Node

enum FactionsType {
	DEFAULT,
	CAT,
	DOG,
	NEUTRAL
};

var allies: Dictionary[FactionsType, bool] = {
	FactionsType.CAT: true
};

var enemies: Dictionary[FactionsType, bool] = {
	FactionsType.DOG: true
};
