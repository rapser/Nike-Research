import UIKit

final class ShoeImageViewController: UIViewController {
    private let image: UIImage?

    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        view = imageView
    }
}
