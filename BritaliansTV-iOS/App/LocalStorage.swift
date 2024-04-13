//
//  LocalStorage.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 18.11.23.
//

import SwiftUI

class LocalStorage {
    static func load<T: Codable>(key: String) -> T? {
        let loadedData = UserDefaults().data(forKey: key)
        
        if let jsonData = loadedData {
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
                
                print("✅ [LocalStorage | load] \t [{\(key)} \(loadedData?.count ?? -1) byte]")
                return decodedData
            } catch {
                print("🚫 [LocalStorage | load] \t Couldn't decode data from key: {\(key)}")
            }
        } else {
            print("🚫 [LocalStorage | load] \t Couldn't load data from key: {\(key)}")
        }
        
        return nil
    }
    
    static func save<T: Codable>(key: String, data: T) {
        do {
            let json = try JSONEncoder().encode(data)
            UserDefaults().set(json, forKey: key)
            
            print("✅ [LocalStorage | save] \t [{\(key)} \(json.count) byte]")
        } catch {
            print("🚫 [LocalStorage | save] \t Couldn't save data: {\(type(of: data))}")
        }
    }
    
    static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        print("✅ [LocalStorage] \t\t [\(key)] data has been successfully deleted.")
    }
}
