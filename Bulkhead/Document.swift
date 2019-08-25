//
//  Document.swift
//  Bulkhead
//
//  Created by John Scott on 24/08/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    @IBOutlet var textView: NSTextView!
    var attributedString: NSAttributedString?
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    override class var autosavesInPlace: Bool {
        return false
    }
    
    override var windowNibName: NSNib.Name? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return NSNib.Name("Document")
    }
    
    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        
        guard let ansiEscapedString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        guard let attributedString = NSAttributedString.decode(ansiEscapedString: ansiEscapedString) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        self.attributedString = attributedString
        
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        if let attributedString = self.attributedString {
            self.textView.textStorage?.setAttributedString(attributedString)
        }
    }
    
    


}

