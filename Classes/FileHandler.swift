//
//  ZipOpener.swift
//  BuildDynamicUi
//
//  Created by Oz Shabat on 27/12/2018.
//  Copyright © 2018 osApps. All rights reserved.
//

import Foundation
import MobileCoreServices

public class FileHandler {
    
    /// Will return the suitable mime type for the file type
    public static func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    /// Will return the file name from a path, with/without the file extension
    public static func getFileNameFromPath(_ url: URL, _ withExtension: Bool) -> String{
        if(withExtension){
            return url.lastPathComponent
        } else {
            return url.deletingPathExtension().lastPathComponent
        }
    }
    
    /// Will check if file or directory exists
    public static func isFileExists(_ url: URL, isDir: Bool = false) -> Bool {
        var isDirectory : ObjCBool = ObjCBool(isDir)
        if FileManager.default.fileExists(atPath: url.path, isDirectory:&isDirectory) {
            return true
        } else {
            return false
        }
    }
    
    ///will check if file or directory exists
    public static func isFileExists(_ pathToFile: String, _ isDir: Bool = false) -> Bool {
        let fileManager = FileManager.default
        var isDirectory : ObjCBool = ObjCBool(isDir)
        if fileManager.fileExists(atPath: pathToFile, isDirectory:&isDirectory) {
            return true
        } else {
            return false
        }
    }
    
    
    /// Will find a file in the current project
    public static func findFileInProject(_ fileName: String, _ fileExtension: String) -> URL? {
        return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
    
    
    /// Will find a file in project by extension and prefix or suffix
    /// todo: filname
    public static func findFilesInProject(fileExtension: String,
                            fileName: String? = nil,
                            filePrefix: String? = nil,
                            fileSuffix: String? = nil) -> [URL] {
        
        // find all of the files match by extension
        var tempFileList =  Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: nil)
        
        // find all of the files match by prefix
        if(filePrefix != nil){
            tempFileList = tempFileList?.filter{ $0.lastPathComponent.range(of: "^\(filePrefix!)", options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        
        // find all of the files match by suffix
        if(fileSuffix != nil){
            tempFileList = tempFileList?.filter{ $0.lastPathComponent.range(of: "\(fileSuffix!)($|\n)", options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        
        
        // build the correct output for the list of files (with the url path and not just the files names)
        var fileList = [URL]()
        tempFileList?.forEach{file in fileList.append(file.absoluteURL)}
        
        return fileList
    }
    
    /// Will create a directory
    @discardableResult
    public static func createDirectory(_ dirPathURL: URL) -> Bool{
        
        do {
            try FileManager.default.createDirectory(atPath: dirPathURL.path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    /// Will copy a file
    public static func copyFile(_ sourcePath: URL, _ clonePath: URL) -> Bool{
        do {
            try FileManager.default.copyItem(at: sourcePath, to: clonePath)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    /**
     Will create a path to a file.
     
     - parameter basePath: the start of the path. a good example will be the path to do documents directory. Try: getDocumentsDir()
     - parameter nextPath: a string of the next path. Could be: zipps\\in\\the\\file. an example:
     let destinationPath = try fh.buildPath(fh.getDocumentsDir(), "\\itzik\\is\\my\\name")
     */
    public static func buildPath(_ basePath: URL, _ nextPath: String) throws -> URL {
        var _basePath = basePath
        var paths = nextPath.split(separator: "/")
        paths = nextPath.split(separator: "\\")
        if(paths.count == 0){
            throw MyError.runtimeError("what is this path? read the instructions of buildPath() function you dummy!")
        }
        
        paths.forEach{ it in
            var newStr = it.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
            newStr = it.replacingOccurrences(of: "/", with: "", options: .literal, range: nil)
            _basePath.appendPathComponent(String(newStr))
        }
        
        return _basePath
    }
    
    /// Will get all of the files URLs from a given path
    public static func getDirectoryContent(_ dirPathURL: URL) -> [URL]?{
        
        do {
            let fileManager = FileManager()
            
            
            //get files from a folder
            let fileURLs = try fileManager.contentsOfDirectory(at: dirPathURL, includingPropertiesForKeys: nil)
            
            //get the names of the files in the folder
            return fileURLs
        } catch {
            print(error)
            return nil
        }
    }
    
    /// Will get all of the directories URLs from a given path
    public static func getSubDirectoriesFromPath(_ dirPathURL: URL) -> [URL]?{
        
            //get files from a folder
            let subDirs = dirPathURL.subDirectories
            //get the names of the files in the folder
            return subDirs
    }
    
    /**
    Returns the URL of the caches directory for the app.

    - Returns: An optional URL object representing the caches directory for the app, or `nil` if the directory cannot be located.
    */
    public static func getCachesDirectoryURL() -> URL? {
        guard let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("Unable to locate caches directory")
            return nil
        }
        return cachesDirectoryURL
    }
    
    /** Returns the parent directory path of the given file URL */
    public static func getParentDirPath(fromFileUrl fileUrl: URL) -> URL? {
        let directoryURL = fileUrl.deletingLastPathComponent()
        guard directoryURL.path != fileUrl.path else {
            return nil // The fileURL is the root directory
        }
        return directoryURL
    }
    
    /// Will delete a file
    public static func deleteFileOrDir(_ filePathURL: URL) {
        try? FileManager.default.removeItem(at: filePathURL)
    }
    
    /**
     Returns the root directory name for a given URL.

     - Parameter url: The URL to extract the root directory name from.
     - Returns: The root directory name of the URL.
    */
    public static func getRootDirectoryName(from url: URL) -> String {
        return url.pathComponents.first ?? ""
    }
    
    /**
     Removes the first root directory from a given URL.

     - Parameter url: The URL to remove the first root directory from.
     - Returns: The URL with the first root directory removed, or the original URL if there is no root directory.
    */
    public static func removeFirstRootDirectory(from url: URL) -> URL {
        var components = url.pathComponents
        
        if components.count > 1 && components[1] != "" {
            components.remove(at: 0)
        }
        
        let path = components.joined(separator: "/")
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.path = path
            
            if let newUrl = urlComponents.url {
                return newUrl
            }
        }
        
        return url
    }
    
    
    
    /// will get the docuemts directory url.
    ///
    /// Application_Home/Documents/ Use this directory to store user documents and application data files.
    ///
    /// Application_Home/Library/ This directory is the top-level directory for files that are not user data files.
    ///
    /// Application_Home/tmp/ Use this directory to write temporary files that do not need to persist between launches of your application.
    public static func getDocumentsDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    
    /// will clear all of the files and dirs in a given path
    public static func removeDirContent(_ dirPath: URL) {
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: dirPath.path)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: "\(dirPath)/\(filePath)")
            }
        } catch {
            print("Could not clear folder: \(error)")
        }
    }
}

public extension URL {
    public var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    public var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
    
    public func joinPath(path: String) -> URL {
        var copy = self
        copy.appendPathComponent(path)
        return copy
    }
    
    /// Return the file size of a given file from URL
    public var fileSize: UInt64? {
        get {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                return attributes[FileAttributeKey.size] as? UInt64
            } catch let error {
                print(error)
                return nil
            }
        }
    }
}

enum MyError: Error {
    case runtimeError(String)
}
