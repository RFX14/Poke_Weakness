struct PokeData: Codable {
    let forms: [PokeForms]
    let sprites: PokeSprites
    let types: [PokeTypes]
}

struct PokeForms: Codable {
    let name: String
}

struct PokeSprites: Codable {
    let front_default: String?
}

struct PokeTypes: Codable {
    let slot: Int
    let type: PokeType
}

//Has it's own struct cause more can be added
struct PokeType: Codable {
    let name: String
    let url: String
}

struct PokeStats: Codable {
    let damage_relations: PokeRelations
}

struct PokeRelations: Codable {
    let double_damage_from: [PokeType]
    let double_damage_to: [PokeType]
}
