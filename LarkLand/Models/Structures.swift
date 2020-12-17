//
//  Structures.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import Foundation

struct UserData {
    var name: String?
    var positionX: Float?
    var positionY: Float?
    var spriteCol: Int?
    var spriteRow: Int?
    
    init(name: String? = nil, positionX: Float? = nil, positionY: Float? = nil, spriteRow: Int? = nil, spriteCol: Int? = nil) {
        self.name = name
        self.positionX = positionX
        self.positionY = positionY
        self.spriteRow = spriteRow
        self.spriteCol = spriteCol
    }
    
}


struct Constants {
    static let officeName = "TikTok iOS"
    static let initPos = [
        "hossein": [0.1,0.5],
        "stephen": [0.5,0.5]
    ] as [String:[Float]]
    static let spritePos = [
        "hossein": [3,1],
        "stephen": [2,5]
    ] as [String: [Int]]
    static let positionX: Float = 0.1
    static let positionY: Float = 0.5
    static let spriteRowHossein: Int = 3
    static let spriteColHossein: Int = 1
    static let spriteRowStephen: Int = 2
    static let spriteColStephen: Int = 5
    static let numSteps: Int = 5
    static let speed: Float = 200.0
    
    static let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTSzRlNjA2NjIxMTBkYmRlNDA4NWEwMThiMGJjODlhZTBkLTE2MDgyNDM0ODAiLCJpc3MiOiJTSzRlNjA2NjIxMTBkYmRlNDA4NWEwMThiMGJjODlhZTBkIiwic3ViIjoiQUNjMGYxN2FmMTkxM2I5N2I1MTg5ZWNiY2RhNmZiM2I2YSIsImV4cCI6MTYwODI0NzA4MCwiZ3JhbnRzIjp7ImlkZW50aXR5IjoiU0tkYmFhN2E5NmE1NWU0ZTVhZjhiZWJlOWQyMzA3Mzc0MiIsInZpZGVvIjp7fX19.filHQIObQ6rU7Jysu7nzr3iOUa6cymaxEuCR78zleZ8"
}
