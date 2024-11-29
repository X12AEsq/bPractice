//
//  AssembleFormattedAddress.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation

struct AssembleFormattedAddress {
    public static func assembleAddress(addr1:String, addr2:String, city:String, state:String, zip: String) ->String {
        var workAddr:String = ""
        let trimAddr1:String = addr1.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimAddr2:String = addr2.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimCity:String = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimState:String = state.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimZip:String = zip.trimmingCharacters(in: .whitespacesAndNewlines)
        workAddr = trimAddr1
        
        if trimAddr2 != "" {
            if workAddr != "" {
                workAddr = workAddr + ", "
            }
            workAddr = workAddr + trimAddr2
        }
        
        if trimCity != "" {
            if workAddr != "" {
                workAddr = workAddr + ", "
            }
            workAddr = workAddr + trimCity
        }
        
        if trimState != "" {
            if workAddr != "" {
                workAddr = workAddr + ", "
            }
            workAddr = workAddr + trimState
        }
        
        if trimZip != "" {
            if workAddr != "" {
                workAddr = workAddr + " "
            }
            workAddr = workAddr + trimZip
        }

        return workAddr
    }
}
