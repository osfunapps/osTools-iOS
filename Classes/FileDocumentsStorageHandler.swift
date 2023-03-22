//
//  SlideshowMusicHandler.swift
//  GeneralRemoteiOS
//
//  Created by Oz Shabbat on 19/03/2023.
//  Copyright © 2023 osApps. All rights reserved.
//

import Foundation

/** Responsible for writing and reading files from the user's documents directory */
public class FileDocumentsStorageHandler {
    
    /**
     Reads a file from the local storage at the specified URL and returns its contents as a `Data` object.
     
     - Parameters:
     - fileName: The name of the file to be read (extension included).
     - fileURL: The URL of the directory where the file is stored.
     
     - Returns: The contents of the file as a `Data` object, or `nil` if the file cannot be read.
     */
    public static func readFileFromStorage(fromDirectoryURL directoryURL: URL,
                                           byFullName fileName: String) -> Data? {
        do {
            let docsPath = FileHandler.getDocumentsDir()
            let directoryPath = try FileHandler.buildPath(docsPath, directoryURL.absoluteString)
            let filePath = try FileHandler.buildPath(directoryPath, fileName)
            if FileHandler.isFileExists(filePath, isDir: false) {
                let data = try Data(contentsOf: filePath)
                return data
            }
        } catch let error {
            print(error)
        }
        return nil
    }
    
    
    /**
     Checks if a file with the specified name exists in the directory located at the given URL.
     
     - Parameters:
     - dirURL: The URL of the directory to search for the file.
     - fileName: The name of the file to search for in the directory (including extension).
     
     - Returns: `true` if the file exists in the directory, `false` otherwise.
     */
    public static func isFileExistsInStorage(locatedInDirURL dirURL: URL,
                                             fileFullName fileName: String) -> Bool {
        do {
            let docsPath = FileHandler.getDocumentsDir()
            let parentPath = try FileHandler.buildPath(docsPath, dirURL.absoluteString)
            let filePath = try FileHandler.buildPath(parentPath, fileName)
            return FileHandler.isFileExists(filePath, isDir: false)
        } catch let error {
            print(error)
        }
        return false
    }
    
    /**
     Writes data to a file in the local storage at the specified URL.
     
     - Parameters:
     - fileName: The name of the file to be written (including extension).
     - dstPath: The local path of the directory where the file will be stored.
     - data: The data to be written to the file.
     
     - Returns: An `Error` object if an error occurs while writing the file, or `nil` if the file is written successfully.
     */
    public static func writeFileToStorage(byFullName fileName: String,
                                          toDstPath dstPath: URL,
                                          withData data: Data) -> Error? {
        do {
            let docsPath = FileHandler.getDocumentsDir()
            let parentDirURL = try FileHandler.buildPath(docsPath, dstPath.absoluteString)
            let fileDstURL = try FileHandler.buildPath(parentDirURL, fileName)
            
            // create the destination directory and any intermediate directories as necessary.
            try FileManager.default.createDirectory(at: parentDirURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
            // delete if previous exists
            if FileHandler.isFileExists(fileDstURL) {
                FileHandler.deleteFileOrDir(fileDstURL)
            }
            
            // write
            try data.write(to: fileDstURL)
            return nil
        } catch let error {
            return error
        }
    }
    
}
