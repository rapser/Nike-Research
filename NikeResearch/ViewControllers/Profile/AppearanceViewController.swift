import UIKit

final class AppearanceViewController: UITableViewController {
    private let viewModel: AppearanceViewModel

    init(viewModel: AppearanceViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.rowHeight = 60
        tableView.tableFooterView = makeFooterView()
        viewModel.onSelectionChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func makeFooterView() -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 70))
        let label = UILabel()
        label.text = viewModel.footer
        label.font = UIFont(name: "AvenirNext-Regular", size: 13) ?? .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])
        return container
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppearanceCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "AppearanceCell")

        var content = cell.defaultContentConfiguration()
        content.text = viewModel.title(at: indexPath.row)
        content.textProperties.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 16) ?? .boldSystemFont(ofSize: 16)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        content.image = UIImage(systemName: viewModel.symbol(at: indexPath.row), withConfiguration: cfg)
        content.imageProperties.tintColor = .label
        cell.contentConfiguration = content

        cell.accessoryType = viewModel.isSelected(at: indexPath.row) ? .checkmark : .none
        cell.tintColor = .label
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectMode(at: indexPath.row)
    }
}
