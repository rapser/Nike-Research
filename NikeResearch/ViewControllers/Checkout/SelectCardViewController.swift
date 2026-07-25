import UIKit

final class SelectCardViewController: UITableViewController {
    private let loadingView = LoadingOverlayView()
    private let viewModel: SelectCardViewModel

    private enum Section: Int { case cards, addNew }

    init(viewModel: SelectCardViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.register(PaymentCardCell.self, forCellReuseIdentifier: PaymentCardCell.reuseID)
        tableView.register(ActionButtonCell.self, forCellReuseIdentifier: ActionButtonCell.reuseID)

        loadingView.useAsBackground(of: tableView)
        viewModel.onStateChanged = { [weak self] in
            guard let self else { return }
            self.loadingView.isLoading = self.viewModel.state == .loading
            self.tableView.reloadData()
        }
        viewModel.onCardsChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCards { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Load Cards"), message: error.localizedDescription)
            }
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == Section.cards.rawValue ? viewModel.cardCount : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.cards.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: PaymentCardCell.reuseID, for: indexPath) as! PaymentCardCell
            let card = viewModel.card(at: indexPath.row)
            cell.configureCard(card: card, isSelected: viewModel.selectedIndex == indexPath.row)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: String(localized: "+ ADD NEW CARD"))
            cell.onActionTapped = { [weak self] in self?.viewModel.addNewCardTapped() }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == Section.cards.rawValue {
            viewModel.selectCard(at: indexPath.row)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == Section.cards.rawValue
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                             forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, indexPath.section == Section.cards.rawValue else { return }
        viewModel.removeCard(at: indexPath.row) { [weak self] error in
            if let error {
                self?.presentAlert(title: String(localized: "Couldn't Remove Card"), message: error.localizedDescription)
                tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
