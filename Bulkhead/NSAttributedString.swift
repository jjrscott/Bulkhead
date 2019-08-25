//
//  NSAttributedString.swift
//  Ash
//
//  Created by John Scott on 21/11/2018.
//

import AppKit

extension NSMutableAttributedString {
    func append(string str: String, attributes attrs: [NSAttributedString.Key : Any]? = nil) {
        append(NSAttributedString(string: str, attributes: attrs))
    }
    
    convenience init?(ansiEscapedString: String, attributesForEscapeSequence: (String, inout [NSAttributedString.Key:Any]) -> Void) {
        self.init()
        
        var attributes = [NSAttributedString.Key:Any]()
        attributesForEscapeSequence("", &attributes)

        if let regularExpression = try? NSRegularExpression(pattern: "\u{1b}\\[([^m]*)m|([^\u{1b}]+)", options: []) {
            regularExpression.enumerateMatches(in: ansiEscapedString, options: [], range: NSRange(location: 0, length: ansiEscapedString.count)) { (textCheckingResult, matchingFlags, _) in
                guard let textCheckingResult = textCheckingResult else { return }
                
                if let textRange = ansiEscapedString.range(from: textCheckingResult.range(at: 2))  {
                    append(string: String(ansiEscapedString[textRange]), attributes: attributes)
                }
                if let escapedRange = ansiEscapedString.range(from: textCheckingResult.range(at: 1))  {
                    let escapeText = String(ansiEscapedString[escapedRange])
                    attributesForEscapeSequence(escapeText, &attributes)
//                    print(attributes)
                }
            }
        }
    }
}

extension NSAttributedString {
    
    static func decode(ansiEscapedString: String) -> NSAttributedString? {
        
        let attributedString = NSMutableAttributedString()
        var unknownEscapeSequenences = Set<String>()
        
        var attributes = [NSAttributedString.Key:Any]()
        let font = NSFont.userFixedPitchFont(ofSize: 11)
        //        let boldFont = font ? NSFont(descriptor: font!.fontDescriptor.withSymbolicTraits(font!x.fontDescriptor.symbolicTraits|UIFontDescriptorTraitBold)), size: <#T##CGFloat#>)
        let boldFont = NSFontManager.shared.convert(NSFont.userFixedPitchFont(ofSize: 10)!, toHaveTrait: .boldFontMask)
        
        
        
        attributes[.font] = font
        attributes[.foregroundColor] = NSColor.controlTextColor
        
        if let regularExpression = try? NSRegularExpression(pattern: "\u{1b}\\[([^m]*)m|([^\u{1b}]*)", options: []) {
            regularExpression.enumerateMatches(in: ansiEscapedString, options: [], range: NSRange(location: 0, length: ansiEscapedString.count)) { (textCheckingResult, matchingFlags, _) in
                guard let textCheckingResult = textCheckingResult else { return }
                
                if let textRange = ansiEscapedString.range(from: textCheckingResult.range(at: 2))  {
                    let text = String(ansiEscapedString[textRange])
                    attributedString.append(string: text, attributes: attributes)
                }
                if let escapedRange = ansiEscapedString.range(from: textCheckingResult.range(at: 1))  {
                    let escapeText = String(ansiEscapedString[escapedRange])
                    
                    let escapeSequence = escapeText.split(separator: ";").compactMap({ Int($0)})
                    switch escapeSequence.tuple() {
                    case .t0, .t1(0):
                        attributes.removeAll()
                        attributes[.font] = font
                        attributes[.foregroundColor] = NSColor.controlTextColor
                    case .t1(1), .t2(1, 1) : attributes[.font] = boldFont
                    case .t1(30), .t2(1, 30) : attributes[.foregroundColor] = NSColor.black
                    case .t1(31), .t2(1, 31) : attributes[.foregroundColor] = NSColor.systemRed
                    case .t1(32), .t2(1, 32) : attributes[.foregroundColor] = NSColor.systemGreen
                    case .t1(33), .t2(1, 33) : attributes[.foregroundColor] = NSColor.systemYellow
                    case .t1(34), .t2(1, 34) : attributes[.foregroundColor] = NSColor.systemBlue
                    case .t1(35), .t2(1, 35) : attributes[.foregroundColor] = NSColor.magenta
                    case .t1(36), .t2(1, 36) : attributes[.foregroundColor] = NSColor.cyan
                    case .t1(37), .t2(1, 37) : attributes[.foregroundColor] = NSColor.darkGray;
                    case .t3(38, 5, let color) :
                        let red = (color - 16) / 36
                        let green = ((color - 16) / 6) % 6
                        let blue = (color - 16) % 6
                        
                        attributes[.foregroundColor] = NSColor(calibratedRed: CGFloat(red)/6, green: CGFloat(green)/6, blue: CGFloat(blue)/6, alpha: 1)
                    case .t1(40), .t2(1, 40) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.00, green: 0.00, blue: 0.00, alpha: 1)
                    case .t1(41), .t2(1, 41) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.59, green: 0.02, blue: 0.05, alpha: 0.6)
                    case .t1(42), .t2(1, 42) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.09, green: 0.64, blue: 0.10, alpha: 0.6)
                    case .t1(43), .t2(1, 43) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.60, green: 0.60, blue: 0.11, alpha: 1)
                    case .t1(44), .t2(1, 44) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.02, green: 0.09, blue: 0.69, alpha: 1)
                    case .t1(45), .t2(1, 45) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.69, green: 0.10, blue: 0.69, alpha: 1)
                    case .t1(46), .t2(1, 46) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.10, green: 0.65, blue: 0.69, alpha: 1)
                    case .t1(47), .t2(1, 47) : attributes[.backgroundColor] = NSColor(calibratedRed: 0.74, green: 0.75, blue: 0.75, alpha: 1)
                    default:
                        attributedString.append(string: "<\(escapeSequence)>", attributes: [NSAttributedString.Key.foregroundColor : NSColor.red])
                        unknownEscapeSequenences.insert(escapeText)
                    }
                    
                }
                
            }
            return attributedString
        }
        else {
            return nil
        }
    }
}
