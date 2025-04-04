//
//  VerifyRepresentation.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/27/24.
//

import Foundation
class VerifyRepresentation {
    public static func verifyRepresentation(internalID: Int, active: Bool, assignedDate: Date, dispositionDate: Date, dispositionType: String, dispositionAction: String, primaryCategory: String, cause:SDCause?, appearances:[SDAppearance]?, notes:[SDNote]?, practice:SDPractice?)  -> ( errNo:Int, errDescr:String ) {
        let aD:Int = DateService.date2Int(inDate: assignedDate)
        let dD:Int = DateService.date2Int(inDate: dispositionDate)
        if internalID < 1 {
            return (errNo: 1, errDescr: "internal id \(internalID) is invalid")
        }
        if aD > dD {
            return (errNo: 2, errDescr: "Disposition date must be greater than or equal to assigned date")
        }
        if cause == nil {
            return (errNo: 3, errDescr: "Must specify a cause")
        }
        let causeStatus = VerifyCause.verifyCause(internalID: cause?.internalID ?? -1, causeNo: cause?.causeNo ?? "", causeType: cause?.causeType ?? "UNK", level: cause?.level ?? "UNK", court: cause?.court ?? "UNK", originalCharge: cause?.originalCharge ?? "", client: cause?.client)
        if causeStatus.errNo != 0 {
            return (errNo: 4, errDescr: "Cause verification failed, \(causeStatus.errNo) -- \(causeStatus.errDescr)")
        }
        return (errNo: 0, errDescr: "")
    }
}
