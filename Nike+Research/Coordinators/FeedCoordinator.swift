import UIKit

final class FeedCoordinator: Coordinator {
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
        let viewModel = FeedViewModel()
        viewModel.onShoeSelected = { [weak self] shoe in
            self?.showDetail(for: shoe)
        }
        let feedVC = FeedViewController(viewModel: viewModel)
        navigationController.viewControllers = [feedVC]
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
