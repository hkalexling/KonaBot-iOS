/**@file libxmlHTMLNode.swift

Kanna

Copyright (c) 2015 Atsushi Kiwaki (@_tid_)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
import libxml2

/**
libxmlHTMLNode
*/
internal final class libxmlHTMLNode: XMLElement {
    var text: String? {
        if nodePtr != nil {
            return libxmlGetNodeContent(nodePtr!)
        }
        return nil
    }
    
    var toHTML: String? {
        let buf = xmlBufferCreate()
        htmlNodeDump(buf, docPtr, nodePtr)
        let html = String(cString: UnsafePointer((buf?.pointee.content)!))
        xmlBufferFree(buf)
        return html
    }

    var toXML: String? {
        let buf = xmlBufferCreate()
        xmlNodeDump(buf, docPtr, nodePtr, 0, 0)
        let html = String(cString: UnsafePointer((buf?.pointee.content)!))
        xmlBufferFree(buf)
        return html
    }
    
    var innerHTML: String? {
        if let html = self.toHTML {
            let inner = html.replacingOccurrences(of: "</[^>]*>$", with: "", options: .regularExpression, range: nil)
                            .replacingOccurrences(of: "^<[^>]*>", with: "", options: .regularExpression, range: nil)
            return inner
        }
        return nil
    }
    
    var className: String? {
        return self["class"]
    }
    
    var tagName:   String? {
        if nodePtr != nil {
            return String(cString: UnsafePointer((nodePtr?.pointee.name)!))
        }
        return nil
    }
    
    private var docPtr:  htmlDocPtr? = nil
    private var nodePtr: xmlNodePtr? = nil
    private var isRoot:  Bool       = false
    
    
    subscript(attributeName: String) -> String?
    {
        get {
            var attr = nodePtr?.pointee.properties
            while attr != nil {
                let mem = attr?.pointee
                if let tagName = String(validatingUTF8: UnsafePointer((mem?.name)!)) {
                    if attributeName == tagName {
                        return libxmlGetNodeContent((mem?.children)!)
                    }
                }
                attr = attr?.pointee.next
            }
            return nil
        }
        
        set(newValue) {
            if let newValue = newValue {
                xmlSetProp(nodePtr, attributeName, newValue)
            } else {
                xmlUnsetProp(nodePtr, attributeName)
            }
        }
    }
    
    init(docPtr: xmlDocPtr) {
        self.docPtr  = docPtr
        self.nodePtr = xmlDocGetRootElement(docPtr)
        self.isRoot  = true
    }
    
    init(docPtr: xmlDocPtr, node: xmlNodePtr) {
        self.docPtr  = docPtr
        self.nodePtr = node
    }
    
    // MARK: Searchable
    func xpath(_ xpath: String, namespaces: [String:String]?) -> XPathObject {
        let ctxt = xmlXPathNewContext(docPtr)
        if ctxt == nil {
            return XPathObject.none
        }
        ctxt?.pointee.node = nodePtr
        
        if let nsDictionary = namespaces {
            for (ns, name) in nsDictionary {
                xmlXPathRegisterNs(ctxt, ns, name)
            }
        }
        
        let result = xmlXPathEvalExpression(xpath, ctxt)
        defer {
            xmlXPathFreeObject(result)
        }
        xmlXPathFreeContext(ctxt)
        if result == nil {
            return XPathObject.none
        }

        return XPathObject(docPtr: docPtr!, object: result!.pointee)
    }
    
    func xpath(_ xpath: String) -> XPathObject {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(_ xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return self.xpath(xpath, namespaces: namespaces).nodeSetValue.first
    }
    
    func at_xpath(_ xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(_ selector: String, namespaces: [String:String]?) -> XPathObject {
        if let xpath = CSS.toXPath(selector) {
            if isRoot {
                return self.xpath(xpath, namespaces: namespaces)
            } else {
                return self.xpath("." + xpath, namespaces: namespaces)
            }
        }
        return XPathObject.none
    }
    
    func css(_ selector: String) -> XPathObject {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(_ selector: String, namespaces: [String:String]?) -> XMLElement? {
        return self.css(selector, namespaces: namespaces).nodeSetValue.first
    }
    
    func at_css(_ selector: String) -> XMLElement? {
        return self.css(selector, namespaces: nil).nodeSetValue.first
    }

    func addPrevSibling(_ node: XMLElement) {
        guard let node = node as? libxmlHTMLNode else {
            return
        }
        xmlAddPrevSibling(nodePtr, node.nodePtr)
    }

    func addNextSibling(_ node: XMLElement) {
        guard let node = node as? libxmlHTMLNode else {
            return
        }
        xmlAddNextSibling(nodePtr, node.nodePtr)
    }
}

private func libxmlGetNodeContent(_ nodePtr: xmlNodePtr) -> String? {
    let content = xmlNodeGetContent(nodePtr)
    if let result  = String(validatingUTF8: UnsafePointer(content!)) {
        content?.deallocateCapacity(1)
        return result
    }
    content?.deallocateCapacity(1)
    return nil
}
