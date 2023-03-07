//
//  FileCacheHandler.swift
//  GeneralRemoteiOS
//
//  Created by Oz Shabbat on 07/03/2023.
//  Copyright © 2023 osApps. All rights reserved.
//

import Foundation

/**
 This class will save/load files in a specific temp directory in the user's phone and thus, act as a cache
 */
public class FileCacheHandler {
    
    private static let CACHE_DIRECTORY_PARENT = "files_cache"
    
    /**
     Saves a file in the cache directory (if the user provided a subdirectory path then save the file in the subdirectory inside the cache dir)
     
     - Parameters:
        - data: The data to save as the contents of the file.
        - fileName: The name of the file to be saved.
        - subdirectory: An optional subdirectory path within the cache directory to save the file in.
     */
    public static func save(data: Data,
                            in subdirectory: String? = nil,
                            toFileWithExtension fileName: String) {
        var cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(CACHE_DIRECTORY_PARENT)
        
        // If a subdirectory is provided, create it if it doesn't exist
        if let subdirectory = subdirectory {
            let subdirectoryURL = cacheDirectory.appendingPathComponent(subdirectory)
            if !FileManager.default.fileExists(atPath: subdirectoryURL.path) {
                try? FileManager.default.createDirectory(at: subdirectoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            cacheDirectory.appendPathComponent(subdirectory)
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        try? data.write(to: fileURL)
    }
    
    /**
     Loads a file from the cache directory (if the user provided a subdirectory path then load the file from the subdirectory inside the cache dir)
     
     - Parameters:
        - file: The name of the file to be loaded.
        - subdirectory: An optional subdirectory path within the cache directory to load the file from.
     - Returns: The URL of the loaded file.
     */
    public static func load(from subdirectory: String? = nil,
                            fileByNameAndExtension file: String) -> URL? {
        var cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(CACHE_DIRECTORY_PARENT)
        
        // If a subdirectory is provided, append it to the cache directory URL
        if let subdirectory = subdirectory {
            cacheDirectory.appendPathComponent(subdirectory)
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(file)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            return nil
        }
    }
    
    /**
     Clears all files from the cache directory and all subdirectories.
     */
    public static func clearAllCache() {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(CACHE_DIRECTORY_PARENT)
        try? FileManager.default.removeItem(at: cacheDirectory)
    }
}
