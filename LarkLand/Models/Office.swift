////
////  Office.swift
////  LarkLand
////
////  Created by Hossein on 12/16/20.
////
//
//import Foundation
//
//class Office {
//    var officeData: OfficeData
//    var officeID: String
//    
//    init(officeID: String) {
//        self.officeID = officeID
//        self.officeData = OfficeData()
//    }
//    
//    init(officeID: String, name: String) {
//        self.officeID = officeID
//        self.officeData = OfficeData(name: name)
//    }
//    
//    
//    
//    func addToDB(completion: @escaping () -> Void) {
//        let office = [
//            "people": officeData.people,
//            "name": officeData.name,
//        ] as [String : Any]
//        db.collection("offices").document(officeID).setData(office)
//        {err in
//            if let err = err {
//                print("Error adding user: \(err)")
//            }
//            completion()
//        }
//    }
//    
//    func readFromDB(completion: @escaping () -> Void) {
//        let officeRef = db.collection("offices").document(officeID)
//        officeRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data()
//                self.officeData.name = dataDescription?["name"] as? String
//                self.officeData.people = dataDescription?["people"] as? [String]
//                completion()
//            } else {
//                print("Document does not exist. inside user class")
//            }
//        }
//    }
//    
//    
//}
