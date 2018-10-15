//
//  NoInternetConnection.swift
//  SubMeet
//
//  Created by carlos arellano on 10/14/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class NoInternetConnection: UIView {

    func configView(width: CGFloat, center: CGPoint, top: CGFloat){
        self.frame = CGRect(x:0, y:0, width: width, height: 20)
        self.backgroundColor = #colorLiteral(red: 1, green: 0.2367687827, blue: 0.2174939764, alpha: 1)
        let centerPoint = CGPoint(x: center.x, y: top + 100)
        self.center = centerPoint
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        label.font = UIFont(name: "Helvetica", size: 12)
        label.textAlignment = .center
        label.text = "No Internet Connection"
        label.center = CGPoint(x: center.x, y: self.frame.height/2)
        label.textColor = .white
        self.addSubview(label)
        NoInternetConnection.animate(withDuration: 0.3, delay: 0.2, options: .curveLinear, animations: {
            var TopFrame = self.frame
            TopFrame.origin.y += 40
            self.frame = TopFrame
        }, completion: { finished in
            print("rect is finished!")
        }
        )
    }
    
    func removeView(){
        NoInternetConnection.animate(withDuration: 0.3, delay: 0.3, options: .curveLinear, animations: {
            var TopFrame = self.frame
            TopFrame.origin.y -= 40
            self.frame = TopFrame
        }, completion: {finished in
            self.removeFromSuperview()
            print("rect is gone!")
        })
    }
    /*
    // Only override draw() if you perform custom drawing.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
*/
}
