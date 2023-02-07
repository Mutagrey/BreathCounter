//
//  CellsDataManager.swift
//  2048Game
//
//  Created by Sergey Petrov on 20.09.2022.
//

import SwiftUI
import Combine

class YogaDataService: DataServiceProtocol  {
    
    /// Root URL  for `SearchPathDirectory` in `userDomainMask`
    private static let rootURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private static let folderURL: URL = YogaDataService.rootURL.appendingPathComponent("Yogas", isDirectory: true)
    
    func loadData() async throws -> [Yoga] {
        try YogaDataService.createFolderIfNeeded(url: YogaDataService.folderURL)
        let fileURLs = try FileManager.default.contentsOfDirectory(at: YogaDataService.folderURL, includingPropertiesForKeys: [])
        
        return try await withThrowingTaskGroup(of: Yoga?.self) { group in
            var results: [Yoga] = []
            results.reserveCapacity(fileURLs.count)
            
            for url in fileURLs {
                group.addTask {
                    let (data, _) = try await URLSession.shared.data(from: url.appendingPathComponent("Yoga.json"))
                    return try? JSONDecoder().decode(Yoga.self, from: data)
                }
            }
            
            for try await yoga in group {
                if let yoga {
                    results.append(yoga)
                } else {
                    print("error to load yoga")
                }
            }
            
            return results
        }
    }
    
    /// Save  to local folder
    func save(_ yoga: Yoga) async throws {
        let folder = YogaDataService.folderURL.appendingPathComponent(yoga.id.uuidString)
        Task{
            do {
                let data = try JSONEncoder().encode(yoga)
                try YogaDataService.createFolderIfNeeded(url: folder)
                let url = folder.appendingPathComponent("Yoga.json")
                try data.write(to: url)
                print("\(url) yoga successfully saved")
            } catch {
                throw error
            }
        }
    }
    
    func remove(_ yoga: Yoga) async throws {
        let jsonURL = YogaDataService.folderURL.appendingPathComponent(yoga.id.uuidString)
        Task{
            do {
                try FileManager.default.removeItem(at: jsonURL)
            } catch {
                print(error.localizedDescription)
                throw error
            }
        }
    }
    
    /// Creates folder if it doesnt exist
    private static func createFolderIfNeeded(url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                print("[📂] Created folder: \(url.path)")
            } catch {
                throw error
            }
        }
    }
}
