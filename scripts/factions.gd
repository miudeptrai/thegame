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

var faction_textures: Dictionary[FactionsType, Texture2D] = {
	FactionsType.DEFAULT: preload("uid://dfrw71egdtutc"),
	FactionsType.CAT: preload("uid://c8tf3u31heigx"),
	FactionsType.NEUTRAL: preload("uid://copnneknxdcc6"),
	FactionsType.DOG: preload("uid://c3cuhk0idky3")
};

func get_texture(faction: FactionsType) -> Texture2D:
	return faction_textures[faction];
