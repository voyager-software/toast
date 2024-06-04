//  Toast.swift
//
//  Created by Gabor Sajo on 2020-05-29.
//  Copyright © 2020 Voyager. All rights reserved.

import Foundation
import UIKit
import NVActivityIndicatorView

public final class Toast: UIView {
    // MARK: Lifecycle

    init(parentView: UIView, text: String, imageName: String, withActivity: Bool = false) {
        super.init(frame: .zero)
        self.removeExistingToasts(from: parentView)
        self.imageView.tintColor = self.tintColor
        self.spinner.color = self.tintColor
        self.label.text = text
        self.setup(parentView, imageName: imageName, withActivity: withActivity)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public enum Duration: TimeInterval {
        case
            minimal = 1,
            short = 3,
            long = 7,
            indefinite = 1000
    }

    public var text: String? {
        get { self.label.text }
        set { self.label.text = newValue }
    }

    public var withActivity: Bool {
        get { !self.spinner.isHidden }
        set { self.spinner.isHidden = !newValue }
    }

    // MARK: Internal

    func show() -> Self {
        self.shownAt = Date()
        UIView.animate(
            withDuration: self.animationTime,
            delay: 0,
            options: .curveEaseOut,
            animations: self.animationsForShow
        )
        return self
    }

    func hide(after delay: TimeInterval = .zero) {
        UIView.animate(
            withDuration: self.animationTime,
            delay: delay,
            options: [],
            animations: self.animationsForHide,
            completion: { _ in
                self.removeFromSuperview()
            }
        )
    }

    // MARK: Private

    private static let font: UIFont = .preferredFont(forTextStyle: .callout)
    private static let spinnerSize: CGFloat = 20

    private let animationTime: TimeInterval = 0.4
    private let insets: UIEdgeInsets = .init(top: 20, left: 20, bottom: 16, right: 16)
    private let topMargin: CGFloat = 16
    private let offScreenPosition: CGFloat = -160
    private let widthMultiplier: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.9 : 0.6

    private var topConstraint: NSLayoutConstraint!
    private var shownAt: Date = .init()

    private let contentView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private let effectView: UIVisualEffectView = {
        let ev = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        ev.translatesAutoresizingMaskIntoConstraints = false
        return ev
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFill
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        ])
        return imageView
    }()

    private let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = Toast.font
        lbl.numberOfLines = 0
        lbl.textColor = .label
        return lbl
    }()

    private let spinner: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: spinnerSize, height: spinnerSize)
        let ai = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .label, padding: 0)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.isHidden = true

        NSLayoutConstraint.activate([
            ai.widthAnchor.constraint(equalToConstant: spinnerSize),
            ai.heightAnchor.constraint(equalToConstant: spinnerSize),
        ])

        return ai
    }()

    @objc private func tapHandler() {
        self.hide()
    }

    private func setup(_ parentView: UIView, imageName: String, withActivity: Bool) {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 20

        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true

        parentView.addSubview(self)

        self.addSubview(self.contentView)
        self.contentView.addSubview(self.effectView)
        self.contentView.addSubview(self.stackView)

        self.imageView.image = UIImage(systemName: imageName)

        self.stackView.addArrangedSubview(self.imageView)
        self.stackView.addArrangedSubview(self.label)
        self.stackView.addArrangedSubview(self.spinner)

        if withActivity {
            self.spinner.isHidden = false
            self.spinner.startAnimating()
        }

        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            self.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: self.widthMultiplier),

            self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.effectView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.effectView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.effectView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.effectView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.stackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: self.insets.left),
            self.stackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -self.insets.right),
            self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: self.insets.top),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -self.insets.bottom),
        ])

        self.alpha = 0
        self.contentView.backgroundColor = .clear

        self.topConstraint = self.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor)
        self.topConstraint.isActive = true
        self.topConstraint.constant = self.offScreenPosition

        parentView.layoutIfNeeded()

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapHandler)))
    }

    private func removeExistingToasts(from parentView: UIView) {
        let toasts = parentView.subviews.compactMap { $0 as? Toast }
        toasts.forEach { $0.hide() }
    }

    private func animationsForShow() {
        self.alpha = 1
        self.topConstraint.constant = self.topMargin
        self.superview?.layoutIfNeeded()
    }

    private func animationsForHide() {
        self.alpha = 0
        self.topConstraint.constant = self.offScreenPosition
        self.superview?.layoutIfNeeded()
    }
}

public extension UIViewController {
    @discardableResult
    func showToast(
        _ message: String,
        imageName: String = "info.circle.fill",
        withActivity: Bool = false,
        duration: Toast.Duration = .short
    ) -> Toast? {
        guard let parentView = UIApplication.shared.appWindow ?? self.view else { return nil }

        let toast = Toast(
            parentView: parentView,
            text: message,
            imageName: imageName,
            withActivity: withActivity
        ).show()

        if duration != .indefinite {
            toast.hide(after: duration.rawValue)
        }

        return toast
    }
}
