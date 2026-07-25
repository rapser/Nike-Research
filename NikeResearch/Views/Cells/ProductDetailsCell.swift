import UIKit

final class ProductDetailsCell: UITableViewCell {
    static let reuseID = "ProductDetailsCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = String(localized: "PRODUCT DETAILS")
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 15) ?? .boldSystemFont(ofSize: 15)
        return l
    }()

    private let chevron: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: cfg))
        iv.tintColor = .black
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private let detailLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .darkGray
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    private lazy var headerRow: UIStackView = {
        UIStackView(arrangedSubviews: [titleLabel, chevron])
    }()

    private lazy var stack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerRow, detailLabel])
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private var isExpanded = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleExpand)))
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(detail: String) {
        detailLabel.text = detail
    }

    @objc private func toggleExpand() {
        isExpanded.toggle()
        detailLabel.isHidden = !isExpanded
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        chevron.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down", withConfiguration: cfg)
        if let tv = superview as? UITableView { tv.performBatchUpdates(nil) }
    }
}
