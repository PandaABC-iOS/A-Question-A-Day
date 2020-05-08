//
//  CardTransition.swift
//  transition
//
//  Created by songzhou on 2020/4/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

final class CardTransition: NSObject {
    init(params: Params) {
        self.params = params
        super.init()
    }
    
    let params: Params

    var pushAnimator: PresentCardAnimator {
        let params = PresentCardAnimator.Params(
            fromCardFrame: self.params.fromCardFrame,
            toCardFrame: self.params.toCardFrame,
            fromCell: self.params.fromCell
        )
        
        return PresentCardAnimator(params: params)
    }
    
    var popAnimator: DismissCardAnimator {
        let params = DismissCardAnimator.Params(
            toCardFrame: self.params.fromCardFrame,
            toCell: self.params.fromCell
        )
        
        return DismissCardAnimator(params: params, fromCardFrame: self.params.toCardFrame)
    }

    struct Params {
        let fromCardFrame: CGRect
        let toCardFrame: CGRect
        let fromCell: UITableViewCell
    }
}
