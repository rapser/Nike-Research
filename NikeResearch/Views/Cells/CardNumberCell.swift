import UIKit

/// Shows the raw digits while the user is typing; once the field loses focus,
/// swaps the display to `**** <last4>` while the real digits stay held in
/// `rawDigits` (and keep flowing to `onNumberChanged`) for Luhn validation and
/// submission. Re-focusing restores the raw digits so the user can correct them.
final class CardNumberCell: UITableViewCell {
    static let reuseID = "CardNumberCell"

    var onNumberChanged: ((String) -> Void)?

    private var rawDigits: String = ""

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = String(localized: "CARD NUMBER")
        l.font = UIFont(name: "AvenirNext-Regular", size: 12) ?? .systemFont(ofSize: 12)
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? .systemFont(ofSize: 15)
        tf.placeholder = String(localized: "Card Number")
        tf.keyboardType = .numberPad
        tf.clearButtonMode = .whileEditing
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textField.delegate = self

        contentView.addSubview(placeholderLabel)
        contentView.addSubview(textField)
        contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            placeholderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            textField.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            separator.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(number: String) {
        rawDigits = number.filter(\.isNumber)
        textField.text = rawDigits.isEmpty ? nil : rawDigits
    }

    @objc private func textDidChange() {
        rawDigits = (textField.text ?? "").filter(\.isNumber)
        onNumberChanged?(rawDigits)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rawDigits = ""
        textField.text = nil
        onNumberChanged = nil
    }
}

extension CardNumberCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = rawDigits.isEmpty ? nil : rawDigits
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard rawDigits.count >= 4 else { return }
        textField.text = "**** \(rawDigits.suffix(4))"
    }
}
