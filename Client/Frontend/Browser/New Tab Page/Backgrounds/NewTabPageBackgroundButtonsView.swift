// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import BraveUI
import BraveShared
import Shared

/// The background view of new tab page which will hold static elements such as
/// the image credit, brand logos or the share by QR code button
///
/// Currently this view displays only a single active button at a time
class NewTabPageBackgroundButtonsView: UIView {
    /// The button kind to display
    enum ActiveButton {
        /// Displays the image credit button showing credit to some `name`
        case imageCredit(_ name: String)
        /// Displays a brands logo button
        case brandLogo(_ logo: NTPLogo)
        /// Displays a button with a little QR code image
        case QRCode
    }
    /// A block executed when a user taps one of the active buttons.
    var tappedActiveButton: ((UIControl) -> Void)?
    /// The current active button.
    ///
    /// Setting this to `nil` hides all button types
    var activeButton: ActiveButton? {
        didSet {
            guard let activeButton = activeButton else {
                activeView = nil
                return
            }
            switch activeButton {
            case .imageCredit(let name):
                imageCreditButton.label.text = String(format: Strings.photoBy, name)
                activeView = imageCreditButton
            case .brandLogo(let logo):
                sponsorLogoButton.imageView.image = logo.image
                activeView = sponsorLogoButton
            case .QRCode:
                activeView = qrCodeButton
            }
        }
    }
    /// The button which is currently showing
    private var activeView: UIView? {
        willSet {
            activeView?.isHidden = true
        }
        didSet {
            activeView?.isHidden = false
        }
    }
    
    private let imageCreditButton = ImageCreditButton().then {
        $0.isHidden = true
    }
    private let sponsorLogoButton = SponsorLogoButton().then {
        $0.isHidden = true
    }
    private let qrCodeButton = QRCodeButton().then {
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        for button in [imageCreditButton, sponsorLogoButton, qrCodeButton] {
            addSubview(button)
            button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)
        }
        
        imageCreditButton.snp.makeConstraints {
            $0.bottom.leading.equalTo(safeAreaLayoutGuide).inset(16)
        }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let isLandscape = frame.width > frame.height
        
        sponsorLogoButton.snp.remakeConstraints {
            $0.size.equalTo(170)
            $0.bottom.equalTo(safeArea.bottom).inset(10)
            
            if isLandscape {
                $0.left.equalTo(safeArea.left).offset(20)
            } else {
                $0.centerX.equalToSuperview()
            }
        }
        
        qrCodeButton.snp.remakeConstraints {
            $0.size.equalTo(48)
            $0.bottom.equalTo(safeArea.bottom).inset(24)
            
            if isLandscape {
                $0.left.equalTo(safeArea.left).offset(48)
            } else {
                $0.centerX.equalToSuperview()
            }
        }
    }
    
    @objc private func tappedButton(_ sender: UIControl) {
        tappedActiveButton?(sender)
    }
}

extension NewTabPageBackgroundButtonsView {
    private class ImageCreditButton: SpringButton, Themeable {
        private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light)).then {
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = false
            $0.layer.cornerRadius = 4
        }
        
        let label = UILabel().then {
            $0.appearanceTextColor = .white
            $0.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(backgroundView)
            backgroundView.contentView.addSubview(label)
            
            backgroundView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            label.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
            }
        }
    }
    private class SponsorLogoButton: SpringButton {
        let imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    private class QRCodeButton: SpringButton {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "qr_code_button"))
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentMode = .scaleAspectFit
            backgroundColor = .white
            clipsToBounds = true
            layer.shadowRadius = 1
            layer.shadowOpacity = 0.5
            
            addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            layer.cornerRadius = bounds.height / 2.0
            layer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
        }
    }
}
