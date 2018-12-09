//
//  WBDirectories.swift
//  DesignDemo
//
//  Created by WangBing on 2018/12/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

import Foundation
enum AppDirectories:String {
    case Documents = "Documents"
    case Inbox     = "Inbox"
    case Library   = "Library"
    case Temp      = "tmp"
}

protocol AppDirectoryNames {
    
    func documentsDirectouryUrl() -> URL
    
    func inboxDirectoryURL() -> URL
    
    func libraryDirectoryURL() -> URL
    
    func tempDirectoryURL() -> URL
    
    func getURL(_ directory: AppDirectories) -> URL
    
    func bulidFullPath(_ name: String,_ directory: AppDirectories) -> URL
}

extension AppDirectoryNames {
    func documentsDirectouryUrl() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func inboxDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Inbox.rawValue) //"Inbox"
    }
    
    func libraryDirectoryURL() -> URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
    }
    
    func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    func getURL(_ directory: AppDirectories) -> URL {
        switch directory {
        case .Documents:
            return documentsDirectouryUrl()
        case .Inbox:
            return inboxDirectoryURL()
        case .Library:
            return libraryDirectoryURL()
        case .Temp:
            return tempDirectoryURL()
        }
    }
    
    func bulidFullPath(_ name: String,_ directory: AppDirectories) -> URL {
        return getURL(directory).appendingPathComponent(name)
    }
}
protocol AppFileStatusChecking {
    
    func isWritable(_ atPath: URL ) -> Bool
    
    func isReadable(_ atPath: URL ) -> Bool
    
    func exists(_ atPath: URL ) -> Bool
}

extension AppFileStatusChecking {
    func isWritable(_ atPath: URL ) -> Bool {
        if FileManager.default.isWritableFile(atPath: atPath.path) {
            print(atPath.path)
            return true
        }else {
            print(atPath.path)
            return false
        }
    }
    
    func isReadable(_ atPath: URL ) -> Bool {
        if FileManager.default.isReadableFile(atPath: atPath.path) {
            print(atPath.path)
            return true
        }else {
            print(atPath.path)
            return false
        }
    }
    
    func exists(_ atPath: URL ) -> Bool {
        if FileManager.default.fileExists(atPath: atPath.path) {
            return true
        }else {
            return false
        }
    }
}
protocol AppFileSystemMetaData {
    func list(_ atPath: URL) -> Bool
    
    func attributes(_ atFullPath:URL) -> [FileAttributeKey : Any]
}
extension AppFileSystemMetaData {
    func list(_ atPath: URL) -> Bool {
        let listing = try! FileManager.default.contentsOfDirectory(atPath: atPath.path)
        if listing.count > 0 {
            print("\n--------------------------------")
            print("LISTING:\(atPath.path)")
            print("")
            for file in listing {
                print("File:\(file.debugDescription)")
            }
            print("")
            print("--------------------------------\n")
            return true
        }else {
            return false
        }
    }
    
    func attributes(_ atFullPath:URL) -> [FileAttributeKey : Any] {
        return try! FileManager.default.attributesOfItem(atPath: atFullPath.path)
    }
}
protocol AppFileManipulation:AppDirectoryNames {
    func writeFile(_ containing: String, path: AppDirectories, name: String) -> Bool
    
    func readFile(_ atPath:AppDirectories, _ name: String) -> String
    
    func deleteFile(_ atPath:AppDirectories, _ name: String) -> Bool
    
    func renameFile(_ atPath:AppDirectories, _ oldName: String, _ newName: String) ->Bool
    
    func moveFile(_ name:String, _ inDirectory: AppDirectories, _ toDirectory: AppDirectories) -> Bool
    
    func copyFile(_ name: String, _ inDirectory: AppDirectories, _ toDirectory: AppDirectories) -> Bool
    
    func changeFileExtension(_ name: String, _ inDirectory: AppDirectories,_ newExtension: String) -> Bool
}
extension AppFileManipulation {
    
    func writeFile(_ containing: String, path: AppDirectories, name: String) -> Bool {
        let filePath = getURL(path).path + "/" + name
        let rawData: Data? = containing.data(using: .utf8)
        return FileManager.default.createFile(atPath: filePath, contents: rawData, attributes: nil)
    }
    
    func readFile(_ atPath:AppDirectories, _ name: String) -> String {
        let filePath = getURL(atPath).path + "/" + name
        let fileContents = FileManager.default.contents(atPath: filePath)
        let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        print("File created with contents: \(fileContentsAsString!)\n")
        return fileContentsAsString!
    }
    
    func deleteFile(_ atPath:AppDirectories, _ name: String) -> Bool {
        let filePath = bulidFullPath(name, atPath)
        try! FileManager.default.removeItem(at: filePath)
        print("\nFile deleted.\n")
        return true
    }
    
    func renameFile(_ atPath:AppDirectories, _ oldName: String, _ newName: String) ->Bool {
        let oldPath = getURL(atPath).appendingPathComponent(oldName)
        let newPath = getURL(atPath).appendingPathComponent(newName)
        try! FileManager.default.moveItem(at: oldPath, to: newPath)
        return true
    }
    
    func moveFile(_ name:String, _ inDirectory: AppDirectories, _ toDirectory: AppDirectories) -> Bool {
        let originURL = bulidFullPath(name, inDirectory)
        let destinationURL = bulidFullPath(name, toDirectory)
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        return true
    }
    
    func copyFile(_ name: String, _ inDirectory: AppDirectories, _ toDirectory: AppDirectories) -> Bool {
        let originURL = bulidFullPath(name, inDirectory)
        let destinationURL = bulidFullPath(name, toDirectory)
        try! FileManager.default.copyItem(at: originURL, to: destinationURL)
        return true
    }
    
    func changeFileExtension(_ name: String, _ inDirectory: AppDirectories,_ newExtension: String) -> Bool {
        var newFileName = NSString(string:name)
        newFileName = newFileName.deletingPathExtension as NSString
        newFileName = (newFileName.appendingPathExtension(newExtension) as NSString?)!
        let finalFileName:String = String(newFileName)
        
        let originURL = bulidFullPath(name, inDirectory)
        let destinationURL = bulidFullPath(finalFileName, inDirectory)
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        return true
    }
    
}

struct iOSAppFileSystemDirectory:AppFileManipulation,AppFileStatusChecking,AppFileSystemMetaData {
    
    let workingDirectory:AppDirectories
    init(_ directory:AppDirectories) {
        self.workingDirectory = directory
    }
    func writeFile(_ containText:String, _ name: String) -> Bool {
        return writeFile(containText, path: workingDirectory, name: name)
    }
    
    func readFile(_ name:String) -> String {
        return readFile(workingDirectory, name)
    }
    
    func deleteFile(_ name:String) -> Bool {
        return deleteFile(workingDirectory, name)
    }
    
    func showAttributes(name:String) -> Void {
        let fullPath = bulidFullPath(name, workingDirectory)
        let fileAttributes = attributes(fullPath)
        for attribute in fileAttributes {
            print(attribute)
        }
    }
    
    func list() {
        list(getURL(workingDirectory))
    }
    
}
