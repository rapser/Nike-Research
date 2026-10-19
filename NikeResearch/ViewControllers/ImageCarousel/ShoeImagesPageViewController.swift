import UIKit

final class ShoeImagesPageViewController: UIPageViewController {
    private let imageURLs: [URL]
    var onPageChanged: ((Int) -> Void)?

    private lazy var controllers: [ShoeImageViewController] = {
        imageURLs.map { ShoeImageViewController(imageURL: $0) }
    }()

    init(imageURLs: [URL]) {
        self.imageURLs = imageURLs
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let first = controllers.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
    }
}

/// El carrusel es cíclico, pero con una sola imagen no puede serlo: devolver el mismo
/// controlador como anterior y siguiente deja a `UIPageViewController` mostrando dos
/// veces la misma instancia y el gesto se rompe. No todos los productos del catálogo
/// traen varias vistas —una gorra o una camiseta pueden tener una sola—, así que ahí
/// simplemente no hay páginas vecinas.
extension ShoeImagesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard controllers.count > 1,
              let current = viewController as? ShoeImageViewController,
              let idx = controllers.firstIndex(of: current) else { return nil }
        let prev = idx == 0 ? controllers.count - 1 : idx - 1
        return controllers[prev]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard controllers.count > 1,
              let current = viewController as? ShoeImageViewController,
              let idx = controllers.firstIndex(of: current) else { return nil }
        let next = (idx + 1) % controllers.count
        return controllers[next]
    }
}

extension ShoeImagesPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = pageViewController.viewControllers?.first as? ShoeImageViewController,
              let idx = controllers.firstIndex(of: current) else { return }
        onPageChanged?(idx)
    }
}
