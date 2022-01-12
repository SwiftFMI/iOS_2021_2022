//
//  ViewController.swift
//  HelloFirebase
//
//  Created by Emil Atanasov on 12.01.22.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var db:Firestore!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        storage = Storage.storage()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickHandler(_ sender: Any) {
//        var ref: DocumentReference? = nil
//        ref = db.collection("pages").addDocument(data: [
//            "first": "Ada",
//            "last": "Lovelace",
//            "born": 1815
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
        
//        db.collection("pages").getDocuments { snapshot, err in
//
//            if let err = err {
//                print("Error reading documents: \(err)")
//            } else if let snapshot:QuerySnapshot = snapshot {
//                snapshot.documents.forEach { doc in
//                    print(doc)
//                    if let _ = doc.get("name") {
//                        //store the id of the document
//                    }
//                }
//            }
//        }
        
        ////pages/UeREE6v01zvgd2rl7Ha6
        ///
//        let data:Dictionary<String, Any> = [
//                        "first": "Ada",
//                        "last": "Lovelace",
//                        "born": 1815
//                    ]
//        let data = ["first" : "Eva"]
//        db.collection("pages").document("UeREE6v01zvgd2rl7Ha6").setData(data, merge: true)
        
        // Data in memory
        if let data = "Hello Firebase Storage!".data(using: .utf8) {
        
            let storageRef = storage.reference()

            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("uploads/test.txt")

        // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }
              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
              riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
              }
            }
            
            // Add a progress observer to an upload task
            let observer = uploadTask.observe(.progress) { snapshot in
              // A progress event occured
                print("Uploading ...", snapshot.progress)
            }
        }
    }
    
}

