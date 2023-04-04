//
//  SlideshowMusicHandler.swift
//  GeneralRemoteiOS
//
//  Created by Oz Shabbat on 19/03/2023.
//  Copyright © 2023 osApps. All rights reserved.
//

import Foundation

/**
 A utility class for working with files in the document directory of the user domain mask.

 The `FileDocumentsStorageHandler` class provides methods for creating, writing to, reading from, and checking the existence of files in the document directory of the user domain mask

*/
public class FileDocumentsStorageHandler {
    
    /**
     Reads the contents of a file at the specified relative URL inside the document directory of the user domain mask.

     - Parameter relativeURL: The relative URL of the file to read.

     - Returns: The contents of the file as a `Data` object, or nil if the file could not be read.
     */
    public static func readFile(byRelativeURL relativeURL: URL) -> Data? {
        do {
            let fullFileURL = try relativeURLToFullURL(relativeURL)
            if FileHandler.isFileExists(fullFileURL, isDir: false) {
                let data = try Data(contentsOf: fullFileURL)
                return data
            }
        } catch let error {
            print(error)
        }
        return nil
    }
    
    
    /**
     Checks if a file exists at the specified relative URL inside the document directory of the user domain mask.

     - Parameter relativeURL: The relative URL of the file to check.

     - Returns: A Boolean value indicating whether the file exists.
     */
    public static func isFileExists(byRelativeURL relativeURL: URL) -> Bool {
        do {
            let fullFileURL = try relativeURLToFullURL(relativeURL)
            return FileHandler.isFileExists(fullFileURL, isDir: false)
        } catch let error {
            print(error)
        }
        return false
    }
    
    /**
     Writes data to a file at the specified relative URL inside the document directory of the user domain mask.

     - Parameters:
       - relativeURL: The relative URL of the file to write data to.
       - data: The data to write to the file.

     - Returns: An error object indicating whether the write operation was successful, or nil if the write operation was successful.
    */
    public static func writeFile(toRelativeURL relativeURL: URL,
                                          withData data: Data) -> Error? {
        do {
            let fullFileURL = try relativeURLToFullURL(relativeURL)
            
            // delete if previous exists
            if FileHandler.isFileExists(fullFileURL) {
                FileHandler.deleteFileOrDir(fullFileURL)
            }
            
            if let fullParentURL = FileHandler.getParentDirPath(fromFileUrl: fullFileURL) {
                // create the destination directory and any intermediate directories as necessary.
                try FileHandler.createDirectory(atPath: fullParentURL, andCreateDirectoriesBetween: true)
            }
            
            // write
            try data.write(to: fullFileURL)
            return nil
        } catch let error {
            return error
        }
    }
    
    /**
     Creates a new directory at the specified relative URL inside the document directory of the user domain mask.

     - Parameters:
     - relativeURL: The relative URL of the directory to create (it can contain multiple subdirectories).

     - Throws: An error if the directory could not be created.

    */
    public static func createDirectory(atRelativeURL relativeURL: URL) throws {
        let fullDirURL = try relativeURLToFullURL(relativeURL)
        try FileHandler.createDirectory(atPath: fullDirURL, andCreateDirectoriesBetween: true)
    }
        
    /**
     Converts a relative URL to a full URL inside the document directory of the user domain mask.
     
     - Parameter relativeURL: The relative URL of the file to convert.
     
     - Returns: A full URL inside the document directory of the user domain mask, or nil if the URL could not be converted.
     */
    public static func relativeURLToFullURL(_ relativeURL: URL) throws -> URL {
        let docsPath = FileHandler.getDocumentsDir()
        return try FileHandler.buildPath(docsPath, relativeURL.absoluteString)
    }
}
