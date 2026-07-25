import UIKit

final class ProfileMenuCell: UITableViewCell {
    static let reuseID = "ProfileMenuCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        tintColor = .black
        textLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 16) ?? .boldSystemFont(ofSize: 16)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, sfSymbol: String) {
        textLabel?.text = title
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        imageView?.image = UIImage(systemName: sfSymbol, withConfiguration: cfg)
        imageView?.tintColor = .black
    }
}
