import UIKit

final class CartCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private weak var checkoutViewModel: CheckoutViewModel?
    private weak var selectCardViewModel: SelectCardViewModel?

    init() {
        navigationController = UINavigationController()
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = .black
    }

    func start() {
        let viewModel = CartViewModel()
        viewModel.onCheckoutTapped = { [weak self] in self?.showCheckout() }
        navigationController.viewControllers = [CartViewController(viewModel: viewModel)]
    }

    private func showCheckout() {
        let vm = CheckoutViewModel()
        checkoutViewModel = vm
        vm.onSelectPaymentTapped = { [weak self] in self?.showSelectCard() }
        vm.onPlaceOrder = { [weak self] order in self?.showPaymentProcessing(order: order) }
        navigationController.pushViewController(CheckoutViewController(viewModel: vm), animated: true)
    }

    private func showSelectCard() {
        let vm = SelectCardViewModel()
        selectCardViewModel = vm
        vm.onCardSelected = { [weak self] card in
            self?.checkoutViewModel?.selectedCard = card
            self?.navigationController.popViewController(animated: true)
        }
        vm.onAddNewCard = { [weak self] in self?.showAddCard() }
        navigationController.pushViewController(SelectCardViewController(viewModel: vm), animated: true)
    }

    private func showAddCard() {
        let vm = AddCardViewModel()
        vm.onCardSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(AddCardViewController(viewModel: vm), animated: true)
    }

    private func showPaymentProcessing(order: Order) {
        let vc = PaymentProcessingViewController(order: order)
        vc.onPaymentComplete = { [weak self] in
            OrdersService.shared.save(order)
            CartService.shared.clearAll()
            self?.showOrderConfirmation(order: order)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showOrderConfirmation(order: Order) {
        let vc = OrderConfirmationViewController(order: order)
        vc.onDismiss = { [weak self] in
            self?.navigationController.popToRootViewController(animated: true)
        }
        navigationController.pushViewController(vc, animated: true)
    }
}
