import UIKit

final class ShoeImageViewController: UIViewController {
    private let imageURL: URL

    init(imageURL: URL) {
        self.imageURL = imageURL
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        let imageView = UIImageView()
        imageView.setRemoteImage(imageURL)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .productCanvas
        view = imageView
    }
}
