import UIKit

final class OrderConfirmationViewController: UIViewController {
    private let order: Order
    var onDismiss: (() -> Void)?

    private let checkmarkView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 64, weight: .thin)
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle", withConfiguration: cfg))
        iv.tintColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = String(localized: "ORDER CONFIRMED!")
        l.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 26) ?? .boldSystemFont(ofSize: 26)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var orderLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
        l.textColor = .darkGray
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        let orderWord = String(localized: "Order")
        let placedSuccessfully = String(localized: "placed successfully.")
        let estimatedDeliveryPrefix = String(localized: "Estimated delivery:")
        l.text = "\(orderWord) \(order.number) \(placedSuccessfully)\n\(estimatedDeliveryPrefix) \(order.estimatedDelivery)"
        return l
    }()

    private lazy var paymentLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        l.textColor = .gray
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "\(String(localized: "Paid with")) \(order.paymentMethod.maskedDisplay)"
        return l
    }()

    private lazy var continueButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(String(localized: "CONTINUE SHOPPING"), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .black
        b.titleLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .boldSystemFont(ofSize: 17)
        b.layer.cornerRadius = 3
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        return b
    }()

    init(order: Order) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(checkmarkView)
        view.addSubview(titleLabel)
        view.addSubview(orderLabel)
        view.addSubview(paymentLabel)
        view.addSubview(continueButton)
        NSLayoutConstraint.activate([
            checkmarkView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),

            titleLabel.topAnchor.constraint(equalTo: checkmarkView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            orderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            orderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            orderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            paymentLabel.topAnchor.constraint(equalTo: orderLabel.bottomAnchor, constant: 8),
            paymentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            paymentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            continueButton.topAnchor.constraint(equalTo: paymentLabel.bottomAnchor, constant: 40),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "ORDER PLACED")
        navigationItem.hidesBackButton = true
    }

    @objc private func continueTapped() { onDismiss?() }
}
