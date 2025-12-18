import Foundation
import TipKit

// MARK: - Tips Configuration

struct QuietlyTips {
    /// Configure TipKit for the app
    static func configure() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    /// Reset all tips for testing
    static func resetTips() {
        try? Tips.resetDatastore()
    }
}

// MARK: - Library Tips

struct AddFirstBookTip: Tip {
    var title: Text {
        Text("Add Your First Book")
    }

    var message: Text? {
        Text("Tap the + button to search for books or add them manually.")
    }

    var image: Image? {
        Image(systemName: "plus.circle.fill")
    }
}

struct ScanBookTip: Tip {
    @Parameter
    static var hasAddedBook: Bool = false

    var title: Text {
        Text("Scan with Your Camera")
    }

    var message: Text? {
        Text("Use your camera to scan book covers or barcodes for quick entry.")
    }

    var image: Image? {
        Image(systemName: "camera.fill")
    }

    var rules: [Rule] {
        #Rule(Self.$hasAddedBook) { $0 == true }
    }
}

// MARK: - Reading Session Tips

struct StartReadingTip: Tip {
    @Parameter
    static var hasAddedBook: Bool = false

    var title: Text {
        Text("Start a Reading Session")
    }

    var message: Text? {
        Text("Track your reading time by starting a session. Tap on any book you're reading to begin.")
    }

    var image: Image? {
        Image(systemName: "play.fill")
    }

    var rules: [Rule] {
        #Rule(Self.$hasAddedBook) { $0 == true }
    }
}

struct ScanTextTip: Tip {
    @Parameter
    static var hasStartedSession: Bool = false

    var title: Text {
        Text("Scan Text from Your Book")
    }

    var message: Text? {
        Text("Tap the scan button to capture text directly from your book using your camera.")
    }

    var image: Image? {
        Image(systemName: "text.viewfinder")
    }

    var rules: [Rule] {
        #Rule(Self.$hasStartedSession) { $0 == true }
    }
}

// MARK: - Goals Tips

struct SetGoalTip: Tip {
    @Parameter
    static var hasCompletedSession: Bool = false

    var title: Text {
        Text("Set Reading Goals")
    }

    var message: Text? {
        Text("Stay motivated by setting daily, weekly, or monthly reading goals.")
    }

    var image: Image? {
        Image(systemName: "target")
    }

    var rules: [Rule] {
        #Rule(Self.$hasCompletedSession) { $0 == true }
    }
}

// MARK: - Notes Tips

struct SwipeToDeleteTip: Tip {
    @Parameter
    static var noteCount: Int = 0

    var title: Text {
        Text("Swipe to Delete")
    }

    var message: Text? {
        Text("Swipe left on any note to delete it.")
    }

    var image: Image? {
        Image(systemName: "hand.draw")
    }

    var rules: [Rule] {
        #Rule(Self.$noteCount) { $0 >= 3 }
    }
}

// MARK: - Context Menu Tip

struct LongPressTip: Tip {
    @Parameter
    static var bookCount: Int = 0

    var title: Text {
        Text("Quick Actions")
    }

    var message: Text? {
        Text("Long press on any book for quick actions like changing status or removing from library.")
    }

    var image: Image? {
        Image(systemName: "hand.tap")
    }

    var rules: [Rule] {
        #Rule(Self.$bookCount) { $0 >= 2 }
    }
}
