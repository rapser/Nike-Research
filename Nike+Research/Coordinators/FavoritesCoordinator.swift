import UIKit

final class FavoritesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var appCoordinator: AppCoordinator?

    init() {
        navigationController = UINavigationController()
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = .black
    }

    func start() {
        let viewModel = FavoritesViewModel()
        let vc = FavoritesViewController(viewModel: viewModel)
        vc.onShoeSelected = { [weak self] shoe in
            self?.showDetail(for: shoe)
        }
        navigationController.viewControllers = [vc]
    }

    private func showDetail(for shoe: Shoe) {
        let viewModel = ShoeDetailViewModel(shoe: shoe)
        viewModel.onAddToCart = { [weak self] shoe in
            CartService.shared.add(shoe: shoe)
            self?.appCoordinator?.updateCartBadge()
        }
        let detailVC = ShoeDetailViewController(viewModel: viewModel)
        detailVC.onSuggestionSelected = { [weak self] suggested in
            self?.showDetail(for: suggested)
        }
        navigationController.pushViewController(detailVC, animated: true)
    }
}
