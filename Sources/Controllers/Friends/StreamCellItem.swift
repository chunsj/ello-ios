//
//  StreamCellItem.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

class StreamCellItem {

    enum CellType {
        case Header
        case CommentHeader
        case Footer
        case BodyElement
        case CommentBodyElement
    }

    let comment:Comment?
    let activity:Activity?
    let type:StreamCellItem.CellType
    let data:Block?
    var cellHeight:CGFloat = 0

    init(activity:Activity, type:StreamCellItem.CellType, data:Block?, cellHeight:CGFloat) {
        self.activity = activity
        self.type = type
        self.data = data
        self.cellHeight = cellHeight
    }
    
    init(comment:Comment, type:StreamCellItem.CellType, data:Block?, cellHeight:CGFloat) {
        self.comment = comment
        self.type = type
        self.data = data
        self.cellHeight = cellHeight
    }
}