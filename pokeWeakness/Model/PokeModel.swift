struct PokeModel {
    let name: String
    let spriteUrl: String
    let type: String
    let type2: String?
}

struct PokeModelStats {
    let weakness: Set<String>
    let effective: Set<String>
}
