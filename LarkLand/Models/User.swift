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


let db = Firestore.firestore()
let storage = Storage.storage()


class User {
    var userData: UserData?
    var userID: String?
    var avatar: UIImage?
    
    init(userID: String) {
        self.userID = userID
        self.userData = UserData()
    }
    
    
    
    func readDataFromDB(completion: @escaping () -> Void) {
        
        let userRef = db.collection("users").document(userID!)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.userData?.name = dataDescription?["name"] as? String
                self.userData?.position = dataDescription?["position"] as? CGPoint
                completion()
            } else {
                print("Document does not exist. inside user class")
            }
        }
    }
    
    func readFromDB(completion: @escaping (UserData) -> Void) {
        self.readDataFromDB {
            self.downloadProfilePhoto(userID: self.userID!) { image in
                self.avatar = image
                completion(self.userData!)
            }
        }
    }
    
    func downloadProfilePhoto(userID: String, completion: @escaping (UIImage) -> Void) {
        completion(UIImage(named: "default.jpg")!)
        var image: UIImage!
        let storageRef = storage.reference(withPath: "profile_pictures/\(userID).png")
        storageRef.getData(maxSize: 100*400*400) {  (data,error) in
            if let data = data {
                image = UIImage(data: data)
                completion(image)
            } else {
                //download the default photo
                storage.reference(withPath: "profile_pictures/default.jpg").getData(maxSize: 100*400*400) {  (data,error) in
                    if let data = data {
                        image = UIImage(data: data)
                        completion(image)
                    }
                }
            }
        }
    }
}



struct UserData {
    
    var name: String?
    var position: CGPoint?
    var spriteCoordinate: [Int]?
    
    init(name: String? = nil, position: CGPoint? = nil, spriteCoordinate: [Int]? = nil) {
        self.name = name
        self.position = position
        self.spriteCoordinate = spriteCoordinate
    }
    
}


struct Office {
    var people: [String]?
    var name: String?
}


struct Constants {
    let officeName = "TikTok iOS"
}
