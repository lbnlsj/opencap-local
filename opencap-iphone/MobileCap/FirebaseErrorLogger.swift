//
//  FirebaseErrorLogger.swift
//  OpenCap
//
//  Created by Nik on 27.06.2023.
//

import UIKit
import Firebase

enum ErrorDomain: String {
    case captureSession = "AVCaptureSession runtime error"

}

class FirebaseErrorLogger {
    static let shared = FirebaseErrorLogger()

    func logError(with domain: ErrorDomain, message: String?) {
        let error = NSError(domain: domain.rawValue,
                            code: 0,
                            userInfo: ["message": message ?? ""])
        Crashlytics.crashlytics().record(error: error)
    }
}
