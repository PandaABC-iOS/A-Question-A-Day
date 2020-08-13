//
//  CustomPrint.swift
//  CustomOperation
//
//  Created by songzhou on 2020/8/8.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

func printLog(_ log: Any) {
    print(_DateFormatter.shared.string(from: Date()), log)
}

private final class _DateFormatter: DateFormatter {
    override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let shared = _DateFormatter()
}
