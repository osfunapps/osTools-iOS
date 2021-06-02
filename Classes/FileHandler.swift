//
//  ZipOpener.swift
//  BuildDynamicUi
//
//  Created by Oz Shabat on 27/12/2018.
//  Copyright © 2018 osApps. All rights reserved.
//

import Foundation

/**
 NOTICE: this file use Zip in cocoa pods. Add in pod file these 2 lines:
 
 source 'https://github.com/CocoaPods/Specs.git'
 pod 'Zip', '~> 1.1'
 
 Thanks.
 **/
//an example to use the file

// a sweet files handler class with a zip example
public class FileHandler{
    
    
    ///will return the file name from a path, with/without the file extension
    public static func getFileNameFromPath(_ url: URL, _ withExtension: Bool) -> String{
        if(withExtension){
            return url.lastPathComponent
        } else {
            return url.deletingPathExtension().lastPathComponent
        }
    }
    
    /// Will read a file to string
    public static func readFile(fileName: String, ext: String) -> String? {
        do {
            let path = Bundle.main.path(forResource: fileName, ofType: ext)
            return try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch let err {
            print(err)
            return nil
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
    
    ///will find a file in the current project
    public static func findFileInProject(_ fileName: String, _ fileExtension: String) -> URL? {
        return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
    
    
    /// will find a file in project by extension and prefix or suffix
    /// todo: filname
    public static func findFilesInProject(_ fileExtension: String,
                            fileName: String? = nil,
                            filePrefix: String? = nil,
                            fileSuffix: String? = nil) -> [URL] {
        
        //find all of the files match by extension
        var tempFileList =  Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: nil)
        
        //find all of the files match by prefix
        if(filePrefix != nil){
            tempFileList = tempFileList?.filter{ $0.lastPathComponent.range(of: "^\(filePrefix!)", options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        
        //find all of the files match by suffix
        if(fileSuffix != nil){
            tempFileList = tempFileList?.filter{ $0.lastPathComponent.range(of: "\(fileSuffix!)($|\n)", options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        
        
        //build the correct output for the list of files (with the url path and not just the files names)
        var fileList = [URL]()
        tempFileList?.forEach{file in fileList.append(file.absoluteURL)}
        
        return fileList
    }
    
    /// will get all of the files URLs from a given path
    public static func getDirectoryContent(_ dirPathURL: URL) -> [URL]?{
        
        do {
            //get files from a folder
            let fileURLs = try FileManager().contentsOfDirectory(at: dirPathURL, includingPropertiesForKeys: nil)
            
            //get the names of the files in the folder
            return fileURLs
        } catch {
            print(error)
            return nil
        }
    }
    
    
    /// will clear all of the files and dirs in a given path
    public static func removeDirContent(_ dirPath: String) {
        let fileManager = FileManager.default
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: dirPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: "\(dirPath)/\(filePath)")
            }
        } catch {
            print("Could not clear folder: \(error)")
        }
    }
    
    
    public static func createFile() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! // file url in Documents folder
        let url = urls.appendingPathComponent("aacSound8.dat").path
        var fileCreated = FileManager().createFile(atPath: url, contents: Data(), attributes: nil)
        print("file created? \(fileCreated)")
    }
    
    public static func appendToFile(data: Data) {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! // file url in Documents folder
        let url = urls.appendingPathComponent("aacSound8.dat")
        print(url.path)
        do {
            let fileHandle = try FileHandle(forWritingTo: url)
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } catch let error {
            print("Error writing to file \(error)")
        }
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
    
    
    /// Will delete a file
    @discardableResult public static func deleteFileOrDir(_ filePathURL: URL) -> Bool {
        do {
            //delete folder
            try FileManager.default.removeItem(at: filePathURL)
            return true
        } catch {
            print(error)
            return false
        }
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
    
    /// Will get all of the directories URLs from a given path
    public static func getSubDirectoriesFromPath(_ dirPathURL: URL) -> [URL]?{
        
            //get files from a folder
            let subDirs = dirPathURL.subDirectories
            //get the names of the files in the folder
            return subDirs
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

extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
    
    public mutating func joinPath(path: String) -> URL {
        self.appendPathComponent(path)
        return self
    }
}

enum MyError: Error {
    case runtimeError(String)
}
