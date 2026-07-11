import UIKit

final class ShoeImagesPageViewController: UIPageViewController {
    private let images: [UIImage]
    var onPageChanged: ((Int) -> Void)?

    private lazy var controllers: [ShoeImageViewController] = {
        images.map { ShoeImageViewController(image: $0) }
    }()

    init(images: [UIImage]) {
        self.images = images
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

extension ShoeImagesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? ShoeImageViewController,
              let idx = controllers.firstIndex(of: current) else { return nil }
        let prev = idx == 0 ? controllers.count - 1 : idx - 1
        return controllers[prev]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let current = viewController as? ShoeImageViewController,
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
