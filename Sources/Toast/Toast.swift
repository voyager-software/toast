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

    public static var iconTint: UIColor = .label
    public static var textColor: UIColor = .label
    public static var font: UIFont = .preferredFont(forTextStyle: .callout)
    public static var insets: UIEdgeInsets = .init(top: 20, left: 20, bottom: 16, right: 16)

    public var text: String? {
        get { self.label.text }
        set { self.label.text = newValue }
    }

    public var withActivity: Bool {
        get { !self.spinner.isHidden }
        set { self.spinner.isHidden = !newValue }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass ||
            traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass
        {
            self.updateConstraintsForCurrentSizeClass()
        }
    }

    // MARK: Internal

    var compactConstraints: [NSLayoutConstraint] = []
    var regularConstraints: [NSLayoutConstraint] = []

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

    private static let spinnerSize: CGFloat = 20

    private let animationTime: TimeInterval = 0.4
    private let topMargin: CGFloat = 16
    private let offScreenPosition: CGFloat = -160

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
        imageView.tintColor = Toast.iconTint
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        ])
        return imageView
    }()

    private let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = Toast.font
        lbl.numberOfLines = 0
        lbl.textColor = Toast.textColor
        return lbl
    }()

    private let spinner: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: spinnerSize, height: spinnerSize)
        let ai = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .label, padding: 0)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.isHidden = true
        ai.color = Toast.iconTint

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

        self.compactConstraints = [
            self.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.9),
        ]

        self.regularConstraints = [
            self.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.6),
        ]

        self.updateConstraintsForCurrentSizeClass()

        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),

            self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.effectView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.effectView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.effectView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.effectView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            self.stackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Self.insets.left),
            self.stackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Self.insets.right),
            self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Self.insets.top),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Self.insets.bottom),
        ])

        self.alpha = 0
        self.contentView.backgroundColor = .clear

        self.topConstraint = self.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor)
        self.topConstraint.isActive = true
        self.topConstraint.constant = self.offScreenPosition

        parentView.layoutIfNeeded()

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapHandler)))
    }

    private func updateConstraintsForCurrentSizeClass() {
        NSLayoutConstraint.deactivate(self.compactConstraints + self.regularConstraints)

        if traitCollection.horizontalSizeClass == .compact {
            NSLayoutConstraint.activate(self.compactConstraints)
        }
        else {
            NSLayoutConstraint.activate(self.regularConstraints)
        }
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
