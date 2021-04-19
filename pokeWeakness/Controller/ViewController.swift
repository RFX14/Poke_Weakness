import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "cell"
    let types = ["Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark", "Fairy"]
    
    var pokeManager = PokeManager()
    var weakness: Set<String> = []
    var effective: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokeManager.delegate = self
        searchField.delegate = self
    }
}

//MARK: - UICollectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionViewCell
        cell.myLabel.text = self.types[indexPath.row]
        cell.layer.cornerRadius = 5

        if weakness.contains(cell.myLabel.text!.lowercased()) {
            cell.backgroundColor = UIColor.red
        } else if effective.contains(cell.myLabel.text!.lowercased()) {
            cell.backgroundColor = UIColor.green
        } else {
            cell.backgroundColor = UIColor.gray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 50.0)
    }
    
}


//MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.endEditing(true)
            return true
        }
        
        textField.placeholder = "Search Pokemon"
        return false
    }
    
    //Once done is pressed on keyboard we actually search
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let pokemon = textField.text {
            print("Looking for: \(pokemon)")
            pokeManager.getPokemonStats(for: pokemon.lowercased())
        }
        searchField.text = ""
    }
}


//MARK: - PokeManagerDelegate
extension ViewController: PokeManagerDelegate {
    func didUpdateStats(_ pokeManager: PokeManager, stats: PokeModelStats) {
        weakness = stats.weakness
        effective = stats.effective
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didUpdatePokemon(_ pokeManager: PokeManager, pokemon: PokeModel) {
        DispatchQueue.main.async {
            self.nameLabel.text = pokemon.name
            self.typeLabel.text = (pokemon.type2 != nil) ? "\(pokemon.type) & \(pokemon.type2!)" : pokemon.type
            
            guard let imageURL = URL(string: pokemon.spriteUrl) else { return }
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            self.imageView.image = image
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

