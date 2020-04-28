// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BraveShared
import BraveUI

/// The current background for a given New Tab Page.
///
/// This class is responsable for providing the background image for 1 new tab
/// page, and altering this based on changes from outside of the NTP such as
/// the user changing Private Mode or disabling the background images prefs
/// while the user is currently viewing a New Tab Page.
class NewTabPageBackground: PreferencesObserver {
    /// The source of new tab page backgrounds
    private let dataSource: NTPBackgroundDataSource
    /// The current background image & possibly sponsor
    private(set) var currentBackground: NTPBackground? {
        didSet {
            changed?()
        }
    }
    /// The background/wallpaper image if available
    var backgroundImage: UIImage? {
        currentBackground?.wallpaper.image
    }
    /// The sponsors logo if available
    var sponsorLogoImage: UIImage? {
        currentBackground?.sponsor?.logo.image
    }
    /// A block called when the current background image/sponsored logo changes
    /// while the New Tab Page is active
    var changed: (() -> Void)?
    /// Create a background holder given a source of all NTP background images
    init(dataSource: NTPBackgroundDataSource) {
        self.dataSource = dataSource
        self.currentBackground = dataSource.newBackground()
        
        NotificationCenter.default.addObserver(self, selector: #selector(privateModeChanged), name: .privacyModeChanged, object: nil)
        
        Preferences.NewTabPage.backgroundImages.observe(from: self)
        Preferences.NewTabPage.backgroundSponsoredImages.observe(from: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func privateModeChanged() {
        self.currentBackground = dataSource.newBackground()
    }
    
    private var timer: Timer?
    
    func preferencesDidChange(for key: String) {
        // Debounce multiple changes to preferences, since toggling bg images
        // cause sponsored images to also be toggled at the same time
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.currentBackground = self.dataSource.newBackground()
        })
    }
}
