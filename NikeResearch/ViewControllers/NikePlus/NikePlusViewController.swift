import UIKit

final class NikePlusViewController: UITableViewController {
    private let viewModel: NikePlusViewModel

    private enum Section: Int, CaseIterable {
        case profile, activities
    }

    init(viewModel: NikePlusViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(NikePlusHeaderCell.self, forCellReuseIdentifier: NikePlusHeaderCell.reuseID)
        tableView.register(NikePlusActivityCell.self, forCellReuseIdentifier: NikePlusActivityCell.reuseID)
        viewModel.onActivitiesChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadActivities { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAlert(title: String(localized: "Couldn't Load Nike+ Activity"), message: error.localizedDescription)
            }
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .profile:    return 1
        case .activities: return viewModel.activityCount
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: NikePlusHeaderCell.reuseID, for: indexPath) as! NikePlusHeaderCell
            cell.configure(image: viewModel.avatarImage, name: viewModel.memberName, memberSince: viewModel.memberSince)
            return cell

        case .activities:
            let cell = tableView.dequeueReusableCell(withIdentifier: NikePlusActivityCell.reuseID, for: indexPath) as! NikePlusActivityCell
            cell.configure(
                title: viewModel.activityTitle(at: indexPath.row),
                value: viewModel.activityValue(at: indexPath.row),
                unit: viewModel.activityUnit(at: indexPath.row)
            )
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section) == .activities ? String(localized: "YOUR ACTIVITY") : nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
