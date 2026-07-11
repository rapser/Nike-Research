import UIKit

final class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private weak var profileViewController: ProfileViewController?

    init() {
        navigationController = UINavigationController()
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = .black
    }

    func start() {
        let vm = ProfileViewModel()
        let vc = ProfileViewController(viewModel: vm)
        vc.onMyCardsTapped = { [weak self] in self?.showMyCards() }
        vc.onMyOrdersTapped = { [weak self] in self?.showMyOrders() }
        vc.onMyAddressesTapped = { [weak self] in self?.showMyAddresses() }
        vc.onLoginTapped = { [weak self] in self?.showLogin() }
        vc.onSignUpTapped = { [weak self] in self?.showRegister() }
        vc.onLogoutTapped = { [weak self] in self?.confirmLogout() }
        profileViewController = vc
        navigationController.viewControllers = [vc]
    }

    private func showLogin() {
        let vm = LoginViewModel()
        let vc = LoginViewController(viewModel: vm)
        vc.onLoginSuccess = { [weak self] in self?.returnToProfile() }
        vc.onSignUpTapped = { [weak self] in self?.showRegister() }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showRegister() {
        let vm = RegisterViewModel()
        let vc = RegisterViewController(viewModel: vm)
        vc.onRegisterSuccess = { [weak self] in self?.returnToProfile() }
        vc.onLogInTapped = { [weak self] in self?.showLogin() }
        navigationController.pushViewController(vc, animated: true)
    }

    private func returnToProfile() {
        navigationController.popToRootViewController(animated: true)
        profileViewController?.refresh()
    }

    private func confirmLogout() {
        let alert = UIAlertController(title: "Log Out",
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            AuthService.shared.logout()
            self?.profileViewController?.refresh()
        })
        navigationController.present(alert, animated: true)
    }

    private func showMyCards() {
        let vm = MyCardsViewModel()
        let vc = MyCardsViewController(viewModel: vm)
        vc.onAddCard = { [weak self] in self?.showAddCard() }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showAddCard() {
        let vm = AddCardViewModel()
        vm.onCardSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(AddCardViewController(viewModel: vm), animated: true)
    }

    private func showMyOrders() {
        let vm = MyOrdersViewModel()
        let vc = MyOrdersViewController(viewModel: vm)
        vc.onOrderSelected = { [weak self] order in
            self?.showOrderDetail(order: order)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showOrderDetail(order: Order) {
        let vm = OrderDetailViewModel(order: order)
        navigationController.pushViewController(OrderDetailViewController(viewModel: vm), animated: true)
    }

    private func showMyAddresses() {
        let vm = MyAddressesViewModel()
        let vc = MyAddressesViewController(viewModel: vm)
        vc.onAddAddress = { [weak self] in self?.showAddAddress() }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showAddAddress() {
        let vm = AddAddressViewModel()
        navigationController.pushViewController(AddAddressViewController(viewModel: vm), animated: true)
    }
}
