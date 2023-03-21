import Foundation
import AppKit
import Highlight

final class JSONTextView: NSTextView {

    let syntaxProvider = JsonSyntaxHighlightProvider()

    override var string: String {
        get { super.string }
        set {
            textStorage?.setAttributedString(makeHighlightedString(from: newValue))
        }
    }

    override func didChangeText() {
        super.didChangeText()

        textStorage?.beginEditing()
        let highlightedString = makeHighlightedString(from: string)
        highlightedString.enumerateAttributes(in: NSRange(location: 0, length: highlightedString.length)) { attr, range, _ in
            textStorage?.setAttributes(attr, range: range)
        }
        textStorage?.endEditing()
    }

    func highlightError(at index: Int) {
        textStorage?.beginEditing()
        let safeIndex = min(string.count - 1, index)
        var attributes = textStorage?.attributes(at: safeIndex, effectiveRange: nil)
        attributes?[NSAttributedString.Key.backgroundColor] = NSColor.red
        textStorage?.setAttributes(attributes, range: NSRange(location: safeIndex, length: 1))
        textStorage?.endEditing()
    }

    private func makeHighlightedString(from string: String) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(string: string)
        syntaxProvider.highlight(mutableString, as: .json)
        return mutableString
    }
}
