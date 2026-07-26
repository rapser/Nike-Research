import UIKit

/// Two boxes side by side (month, year), each backed by a native `UIPickerView`
/// wheel set as the text field's `inputView` — tapping either opens the picker
/// as the keyboard, exactly like a native date picker input.
final class ExpiryDateCell: UITableViewCell {
    static let reuseID = "ExpiryDateCell"

    var onExpiryChanged: ((_ month: Int, _ year: Int) -> Void)?

    private let months = Array(1...12)
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(currentYear...(currentYear + 15))
    }()

    private var selectedMonthIndex = 0
    private var selectedYearIndex = 0

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = String(localized: "EXPIRY DATE")
        l.font = UIFont(name: "AvenirNext-Regular", size: 12) ?? .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var monthField = makeField(placeholder: String(localized: "MM"))
    private lazy var yearField = makeField(placeholder: String(localized: "YYYY"))

    private lazy var monthPicker: UIPickerView = {
        let p = UIPickerView()
        p.delegate = self
        p.dataSource = self
        p.tag = 0
        return p
    }()

    private lazy var yearPicker: UIPickerView = {
        let p = UIPickerView()
        p.delegate = self
        p.dataSource = self
        p.tag = 1
        return p
    }()

    private lazy var fieldsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [monthField, yearField])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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

        monthField.inputView = monthPicker
        monthField.inputAccessoryView = makeToolbar()
        yearField.inputView = yearPicker
        yearField.inputAccessoryView = makeToolbar()

        contentView.addSubview(titleLabel)
        contentView.addSubview(fieldsStack)
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            fieldsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            fieldsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            fieldsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24),
            fieldsStack.heightAnchor.constraint(equalToConstant: 36),

            separator.topAnchor.constraint(equalTo: fieldsStack.bottomAnchor, constant: 10),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        refreshFieldText()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? .systemFont(ofSize: 15)
        tf.textAlignment = .center
        tf.borderStyle = .roundedRect
        tf.tintColor = .clear
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }

    private func makeToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: String(localized: "Done"), style: .done, target: self, action: #selector(doneTapped))
        toolbar.items = [flex, done]
        return toolbar
    }

    @objc private func doneTapped() {
        endEditing(true)
    }

    /// `month` is 1-12, `year` is a full year (e.g. 2028).
    func configure(month: Int, year: Int) {
        selectedMonthIndex = months.firstIndex(of: month) ?? 0
        selectedYearIndex = years.firstIndex(of: year) ?? 0
        monthPicker.selectRow(selectedMonthIndex, inComponent: 0, animated: false)
        yearPicker.selectRow(selectedYearIndex, inComponent: 0, animated: false)
        refreshFieldText()
    }

    private func refreshFieldText() {
        monthField.text = String(format: "%02d", months[selectedMonthIndex])
        yearField.text = String(years[selectedYearIndex])
    }
}

extension ExpiryDateCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView.tag == 0 ? months.count : years.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView.tag == 0 ? String(format: "%02d", months[row]) : String(years[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            selectedMonthIndex = row
        } else {
            selectedYearIndex = row
        }
        refreshFieldText()
        onExpiryChanged?(months[selectedMonthIndex], years[selectedYearIndex])
    }
}
