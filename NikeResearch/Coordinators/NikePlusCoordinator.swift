import UIKit

final class NikePlusCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    init() {
        navigationController = UINavigationController()
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = .label
    }

    func start() {
        let viewModel = NikePlusViewModel()
        let vc = NikePlusViewController(viewModel: viewModel)
        navigationController.viewControllers = [vc]
    }
}
