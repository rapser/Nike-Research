import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()

    private let window: UIWindow
    private let tabBarController = UITabBarController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let feedCoordinator = FeedCoordinator()
        let cartCoordinator = CartCoordinator()
        let favoritesCoordinator = FavoritesCoordinator()
        let nikePlusCoordinator = NikePlusCoordinator()
        let profileCoordinator = ProfileCoordinator()

        addChild(feedCoordinator)
        addChild(cartCoordinator)
        addChild(favoritesCoordinator)
        addChild(nikePlusCoordinator)
        addChild(profileCoordinator)

        feedCoordinator.appCoordinator = self
        favoritesCoordinator.appCoordinator = self

        feedCoordinator.start()
        cartCoordinator.start()
        favoritesCoordinator.start()
        nikePlusCoordinator.start()
        profileCoordinator.start()

        let feedNav = feedCoordinator.navigationController
        feedNav.tabBarItem = makeTabItem(image: "icon-home", selected: "icon-home")

        let cartNav = cartCoordinator.navigationController
        cartNav.tabBarItem = makeTabItem(image: "icon-bag", selected: "icon-bag-filled")

        let favNav = favoritesCoordinator.navigationController
        favNav.tabBarItem = makeTabItem(image: "icon-plus", selected: "icon-plus")

        let nikePlusNav = nikePlusCoordinator.navigationController
        nikePlusNav.tabBarItem = makeTabItem(image: "icon-nike", selected: "icon-nike-filled")

        let profileNav = profileCoordinator.navigationController
        profileNav.tabBarItem = makeSymbolTabItem(symbol: "person", selectedSymbol: "person.fill")

        tabBarController.viewControllers = [feedNav, cartNav, favNav, nikePlusNav, profileNav]
        tabBarController.tabBar.tintColor = .label
        window.rootViewController = tabBarController

        // Every cart mutation (add/remove/update-quantity/clear/fetch, from any
        // screen) routes through CartService, so this one subscription keeps the
        // badge correct everywhere instead of updating it ad hoc per call site.
        CartService.shared.onCartUpdate { [weak self] in
            self?.updateCartBadge()
        }
        if AuthService.shared.isAuthenticated {
            CartService.shared.fetchCart { _ in }
            // Primes FavoritesService's cache so the heart on a shoe detail
            // screen is correct even if the user hasn't visited the Favorites
            // tab yet this launch.
            FavoritesService.shared.fetchFavorites { _ in }
        }
    }

    private func makeTabItem(image: String, selected: String) -> UITabBarItem {
        let item = UITabBarItem(title: nil,
                                image: UIImage(named: image),
                                selectedImage: UIImage(named: selected))
        item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return item
    }

    private func makeSymbolTabItem(symbol: String, selectedSymbol: String) -> UITabBarItem {
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
        let item = UITabBarItem(title: nil,
                                image: UIImage(systemName: symbol, withConfiguration: cfg),
                                selectedImage: UIImage(systemName: selectedSymbol, withConfiguration: cfg))
        item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return item
    }

    func updateCartBadge() {
        let count = CartService.shared.totalItemCount
        tabBarController.tabBar.items?[1].badgeValue = count > 0 ? "\(count)" : nil
    }
}
