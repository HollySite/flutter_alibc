//
//  TrvZipArchiver.swift
//  flutter_alibc
//
//  Created by 邓先舜 on 2021/10/27.
//

import Foundation
import SSZipArchive

class ZipArchiverOp: NSObject, TRVZipOperationProtocol {
    
    private var _innerArchiver: SSZipArchive?
    private var _zipFile: String?
    
    func unzipOpenFile(_ zipFile: String) -> Bool {
        _zipFile = zipFile
        return true
    }
    
    func unzipCloseFile() -> Bool {
        return true
    }
    
    func unzipFile(to path: String, overWrite: Bool) -> Bool {
        return SSZipArchive.unzipFile(atPath: _zipFile ?? "", toDestination: path)
    }
}

class TrvZipArchiver: NSObject, TRVZipArchiveProtocol {
    func zipArchiverInstance() -> TRVZipOperationProtocol! {
        return ZipArchiverOp()
    }
}
