//
//  InfoBarView.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit

final class InfoBarView: UIView {
    // MARK: - UI

    private let messageLabel = UILabel()
    private let panGestureRecognizer = UIPanGestureRecognizer()

    // MARK: - Properties

    var doAfter: (() -> Void)?
    private var originalPosition: CGPoint!
    private var draggingUp = false
    private var topPadding: CGFloat?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        self.hide()
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(dragging(_:)))
    }

    private func setupUI() {
        Styles.messageLabel.apply(to: messageLabel)

        addSubview(messageLabel)

        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(topPadding ?? 40)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - Actions

    func show(message: String, offset: CGFloat = 0) {
        messageLabel.text = message

        self.frame.origin = CGPoint(x: 0, y: (-1 * self.frame.height))
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.origin.y = 0
        }, completion: { _ in })
    }

    func hide() {
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.origin.y -= self.frame.height
        }, completion: { _ in
            self.isHidden = true
            self.removeFromSuperview()
            self.doAfter?()
        })
    }

    @objc
    private func dragging(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            if recognizer.state == .began {
                originalPosition = view.center
            } else if recognizer.state == .changed {
                let translation = recognizer.translation(in: self)
                draggingUp = translation.y < 0    // store last direction
                var newY = view.center.y + translation.y
                if newY > originalPosition.y {
                    newY = originalPosition.y
                }
                view.center = CGPoint(x: view.center.x, y: newY)
                recognizer.setTranslation(CGPoint.zero, in: self)
            } else if recognizer.state == .ended {
                if draggingUp {
                    hide()
                } else {
                    // return view to original position (duration depends on distance from original position)
                    let duration = abs(originalPosition.y - view.center.y) / self.frame.height
                    recognizer.setTranslation(CGPoint.zero, in: self)
                    UIView.animate(withDuration: TimeInterval(duration)) {
                        view.center = self.originalPosition
                    }
                }
            }
        }
    }
}

// MARK: - Styles

extension InfoBarView {
    struct Styles {
        static let messageLabel = UIViewStyle<UILabel> {
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.7
            $0.font = Appearance.font(ofSize: 15)
            $0.textColor = .white
            $0.textAlignment = .left
        }
    }
}

// MARK: - Create

extension InfoBarView {
    static func create(frame: CGRect, backgroundColor: UIColor? = .red) -> InfoBarView {
        let infoBar = InfoBarView()
        infoBar.backgroundColor = backgroundColor
        infoBar.topPadding = frame.height
        return infoBar
    }
}
