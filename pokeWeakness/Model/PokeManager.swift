import Foundation

protocol PokeManagerDelegate {
    func didUpdatePokemon(_ pokeManager: PokeManager, pokemon: PokeModel)
    func didUpdateStats(_ pokeManager: PokeManager, stats: PokeModelStats)
    func didFailWithError(error: Error)
}

struct PokeManager {
    let baseUrl = "https://pokeapi.co/api/v2/pokemon/"
    
    var delegate: PokeManagerDelegate?
    
    func getPokemonStats(for pokemon: String) {
        let urlString = "\(baseUrl)\(pokemon)"
        let fixedurlString = String(urlString.filter { !$0.isWhitespace })
        performRequest(with: fixedurlString, isPokemon: true)
    }
    
    func performRequest(with urlString: String, isPokemon: Bool) {
        if let url = URL(string: urlString) {
            //print("We are performing URL Request")
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, responose, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if isPokemon {
                        if let pokemon = parseJSON(safeData) {
                            delegate?.didUpdatePokemon(self, pokemon: pokemon)
                        }
                    } else {
                        if let stats = parseJSONStats(safeData) {
                            delegate?.didUpdateStats(self, stats: stats)
                        }
                    }
                    
                }
            }
            task.resume()
        }
        //print("Couldn't perform URL Request")
    }
    
    func parseJSONStats(_ pokeData: Data) -> PokeModelStats? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(PokeStats.self, from: pokeData)
            
            var weakness:Set<String> = []
            for group in decodedData.damage_relations.double_damage_from {
                weakness.insert(group.name)
            }
            
            var effective:Set<String> = []
            for group in decodedData.damage_relations.double_damage_to {
                effective.insert(group.name)
            }
            
            print(weakness)
            print(effective)
            
            let stats = PokeModelStats(weakness: weakness, effective: effective)
            return stats
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ pokeData: Data) -> PokeModel? {
        let decoder = JSONDecoder()
        
        do {
            print("We are decoding!")
            let decodedData = try decoder.decode(PokeData.self, from: pokeData)
            let name = decodedData.forms[0].name
            let spriteURL = decodedData.sprites.front_default
            let type = decodedData.types[0].type.name
            let type2 = (decodedData.types.count > 1) ? decodedData.types[1].type.name : nil
            
            performRequest(with: decodedData.types[0].type.url, isPokemon: false)
            
            let pokemon = PokeModel(name: name, spriteUrl: spriteURL!, type: type, type2: type2)
            return pokemon
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
