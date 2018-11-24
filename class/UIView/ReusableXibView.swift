//
//  ReusableXibView.swift
//
//  Created by Arjan on 24-11-18.
//

import UIKit

/**
 XIB class counterparts can inherit from this class and do not need any instantiating code.
 - note: XIBs instantiated through the File's Owner may not call `awakeFromNib`
 
 - important:
 Works only with XIBs
 - with only one `UIView`,
 - of which the outlets are connected through the File's Owner and NOT by setting the class of it's `UIView`,
 - and that have the exact same name as the underlying class (also the File's Owner)
 */
class WMReusableXibView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        let xibName = String(describing: type(of: self)) // we expect a XIB with exactly the same name
        let nib = UINib(nibName: xibName, bundle: nil).instantiate(withOwner: self, options: nil) // of which this class is the owner
        let content = nib[0] as! UIView // we expect only one view in the XIB
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
