import UIKit
import MapKit

final class AddAddressViewController: UIViewController {
    private let viewModel: AddAddressViewModel

    private let mapView: MKMapView = {
        let m = MKMapView()
        m.translatesAutoresizingMaskIntoConstraints = false
        m.isZoomEnabled = true
        m.isScrollEnabled = true
        return m
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = String(localized: "Search for an address")
        sb.backgroundImage = UIImage()
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private lazy var resultsTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isHidden = true
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.rowHeight = 60
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        return tv
    }()

    private lazy var formTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 54
        tv.keyboardDismissMode = .onDrag
        tv.register(BillingFormCell.self, forCellReuseIdentifier: BillingFormCell.reuseID)
        tv.register(ActionButtonCell.self, forCellReuseIdentifier: ActionButtonCell.reuseID)
        return tv
    }()

    private var searchResults: [MKMapItem] = []

    private enum Row: Int, CaseIterable {
        case street, city, state, zip, country, save
    }

    init(viewModel: AddAddressViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(formTableView)
        view.addSubview(resultsTableView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 220),

            searchBar.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            formTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            formTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            resultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 2),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultsTableView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    private func updateResultsBorder() {
        resultsTableView.layer.borderColor = UIColor.separator.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title

        // El borde es un `CGColor`, un valor ya resuelto que no se reevalúa al cambiar
        // de claro a oscuro, así que hay que volver a aplicarlo a mano.
        updateResultsBorder()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (vc: Self, _) in
            vc.updateResultsBorder()
        }

        searchBar.delegate = self
        formTableView.dataSource = self
        formTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.delegate = self

        viewModel.onSearchResults = { [weak self] items in
            guard let self else { return }
            self.searchResults = items
            self.resultsTableView.reloadData()
            self.resultsTableView.isHidden = items.isEmpty
        }

        viewModel.onAddressSelected = { [weak self] in
            guard let self else { return }
            self.searchBar.text = ""
            self.resultsTableView.isHidden = true
            self.searchBar.resignFirstResponder()
            self.formTableView.reloadData()
            if let coord = self.viewModel.selectedCoordinate {
                self.zoomMap(to: coord)
            }
        }

        viewModel.onAddressSaved = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        if let coord = viewModel.selectedCoordinate {
            zoomMap(to: coord)
        } else {
            centerMapOnUS()
        }
    }

    private func centerMapOnUS() {
        let center = CLLocationCoordinate2D(latitude: 39.5, longitude: -98.35)
        let span = MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
    }

    private func zoomMap(to coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = viewModel.street
        mapView.addAnnotation(pin)
    }
}

// MARK: — UISearchBarDelegate

extension AddAddressViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.search(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        resultsTableView.isHidden = true
        viewModel.search(query: "")
    }
}

// MARK: — UITableViewDataSource

extension AddAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === resultsTableView { return searchResults.count }
        return Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === resultsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
            let item = searchResults[indexPath.row]
            cell.textLabel?.text = item.name ?? item.placemark.title
            cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14) ?? .systemFont(ofSize: 14)
            cell.textLabel?.numberOfLines = 2
            cell.detailTextLabel?.text = item.placemark.title
            return cell
        }

        let row = Row(rawValue: indexPath.row)!
        if row == .save {
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionButtonCell.reuseID, for: indexPath) as! ActionButtonCell
            cell.configure(title: viewModel.saveButtonTitle, enabled: viewModel.isValid)
            cell.onActionTapped = { [weak self] in self?.handleSave() }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: BillingFormCell.reuseID, for: indexPath) as! BillingFormCell
        switch row {
        case .street:
            cell.configure(placeholder: String(localized: "Street"), text: viewModel.street)
            cell.onTextChanged = { [weak self] in self?.viewModel.street = $0; self?.reloadSaveRow() }
        case .city:
            cell.configure(placeholder: String(localized: "City"), text: viewModel.city)
            cell.onTextChanged = { [weak self] in self?.viewModel.city = $0; self?.reloadSaveRow() }
        case .state:
            cell.configure(placeholder: String(localized: "State / Province"), text: viewModel.state)
            cell.onTextChanged = { [weak self] in self?.viewModel.state = $0 }
        case .zip:
            cell.configure(placeholder: String(localized: "ZIP / Postal Code"), text: viewModel.zipCode, keyboardType: .numberPad)
            cell.onTextChanged = { [weak self] in self?.viewModel.zipCode = $0; self?.reloadSaveRow() }
        case .country:
            cell.configure(placeholder: String(localized: "Country"), text: viewModel.country)
            cell.onTextChanged = { [weak self] in self?.viewModel.country = $0 }
        case .save: break
        }
        return cell
    }

    private func reloadSaveRow() {
        let saveIndexPath = IndexPath(row: Row.save.rawValue, section: 0)
        formTableView.reloadRows(at: [saveIndexPath], with: .none)
    }
}

// MARK: — UITableViewDelegate

extension AddAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView === resultsTableView {
            let item = searchResults[indexPath.row]
            viewModel.selectMapItem(item)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === resultsTableView { return 60 }
        return UITableView.automaticDimension
    }
}

// MARK: — Save

private extension AddAddressViewController {
    func handleSave() {
        guard viewModel.isValid else {
            presentAlert(title: String(localized: "Missing Information"), message: String(localized: "Please fill in the street, city, and ZIP code."))
            return
        }
        setSaving(true)
        viewModel.saveAddress { [weak self] error in
            self?.setSaving(false)
            if let error {
                self?.presentAlert(title: String(localized: "Couldn't Save Address"), message: error.localizedDescription)
            }
        }
    }

    func setSaving(_ saving: Bool) {
        guard let cell = formTableView.cellForRow(at: IndexPath(row: Row.save.rawValue, section: 0)) as? ActionButtonCell else { return }
        cell.configure(title: saving ? String(localized: "SAVING...") : viewModel.saveButtonTitle, enabled: !saving && viewModel.isValid)
    }
}
