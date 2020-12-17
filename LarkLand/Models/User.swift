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
    
    init(userID: String) {
        self.userID = userID
        self.userData = UserData()
    }
    
    init(userID: String, name: String) {
        self.userID = userID
        self.userData = UserData(name: name)
    }
    
    init(userID: String? = nil, name: String, positionX: Float, positionY: Float, spriteRow: Int, spriteCol: Int) {
        self.userID = userID!
        self.userData = UserData(name: name, positionX: positionX, positionY: positionY, spriteRow: spriteRow, spriteCol: spriteCol)
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
