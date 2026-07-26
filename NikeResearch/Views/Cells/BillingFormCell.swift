import UIKit

final class BillingFormCell: UITableViewCell {
    static let reuseID = "BillingFormCell"

    var onTextChanged: ((String) -> Void)?

    let textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? .systemFont(ofSize: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 12) ?? .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
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

    func configure(placeholder: String, text: String = "", keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
        placeholderLabel.text = placeholder.uppercased()
        textField.placeholder = placeholder
        textField.text = text.isEmpty ? nil : text
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
    }

    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        onTextChanged = nil
    }
}
