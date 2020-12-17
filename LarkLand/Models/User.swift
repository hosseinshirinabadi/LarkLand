//
//  User.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import Foundation
import UIKit
import CoreData
import Firebase



class User {
    var userData: UserData
    var userID: String
    var avatar: UIImage?
    
    init(userID: String) {
        self.userID = userID
        self.userData = UserData()
    }
    
    init(userID: String, name: String) {
        self.userID = userID
        self.userData = UserData(name: name)
    }
    
    func addToDB(completion: @escaping () -> Void) {
        let userdata = [
            "name": userData.name,
            "positionX": userData.positionX,
            "positionY": userData.positionY,
            "spriteRow": userData.spriteRow,
            "spriteCol": userData.spriteCol,
        ] as [String : Any]
        db.collection("users").document(userID).setData(userdata)
        {err in
            if let err = err {
                print("Error adding user: \(err)")
            }
            completion()
        }
        
    }
    
    func readFromDB(completion: @escaping () -> Void) {
        
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.userData.name = dataDescription?["name"] as? String
                self.userData.positionX = dataDescription?["positionX"] as? Float
                self.userData.positionY = dataDescription?["positionY"] as? Float
                self.userData.spriteRow = dataDescription?["spriteRow"] as? Int
                self.userData.spriteCol = dataDescription?["spriteCol"] as? Int

                completion()
            } else {
                print("Document does not exist. inside user class")
            }
        }
    }
    
    func setPosition(positionX: Float, positionY: Float) {
        self.userData.positionX = positionX
        self.userData.positionY = positionY
    }
    
    func setSprite(spriteRow: Int, spriteCol: Int) {
        self.userData.spriteRow = spriteRow
        self.userData.spriteCol = spriteCol
    }
    
    
    
    
}



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


struct Office {
    var people: [String]?
    var name: String?
}


struct Constants {
    static let officeName = "TikTok iOS"
    static let positionX: Float = 0.1
    static let positionY: Float = 0.5
    static let spriteRowHossein: Int = 1
    static let spriteColHossein: Int = 8
}
