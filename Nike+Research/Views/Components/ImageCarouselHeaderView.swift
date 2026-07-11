import UIKit

final class ImageCarouselHeaderView: UIView {
    let carouselContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()

    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(carouselContainer)
        addSubview(pageControl)
        NSLayoutConstraint.activate([
            carouselContainer.topAnchor.constraint(equalTo: topAnchor),
            carouselContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            carouselContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            carouselContainer.heightAnchor.constraint(equalTo: carouselContainer.widthAnchor),

            pageControl.topAnchor.constraint(equalTo: carouselContainer.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
