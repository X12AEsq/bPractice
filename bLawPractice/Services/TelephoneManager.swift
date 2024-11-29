//
//  TelephoneManager.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/19/24.
//

import Foundation
class TelephoneManager {
    public static func areaCode(number:String) -> String {
        return self.substr(input: self.delDash(input: number), begin: 0, end: 2)
    }
    public static func exchange(number:String) -> String {
        return self.substr(input: self.delDash(input: number), begin: 3, end: 5)
    }
    public static func number(number:String) -> String {
        return self.substr(input: self.delDash(input: number), begin: 6, end: 9)
    }
    private static func delDash(input:String) -> String {
        var work = input
        let removeCharacters: Set<Character> = ["-"]
        work.removeAll(where: { removeCharacters.contains($0) } )
        return work
    }
    private static func substr(input:String, begin:Int, end:Int) -> String {
        var work = input
        if end <= begin { return "" }
        while work.count < 15 { work.append("0") }
        let start = work.index(work.startIndex, offsetBy: begin)
        let stop = work.index(work.startIndex, offsetBy: end)
                 // get a sub-string with a ClosedRange
        let range = start...stop
        let substring = work[range]
        return String(substring)
    }
    public static func assembleNumber(areaCode:String, exchange:String, number:String) -> String {
        var n1:String = areaCode
        var n2:String = exchange
        var n3:String = number
        while n1.count < 3 { n1 = n1 + "0" }
        while n2.count < 3 { n2 = n2 + "0" }
        while n3.count < 4 { n3 = n3 + "0" }
        if n1.count > 3 {
            let start = n1.index(n1.startIndex, offsetBy: 0)
            let stop = n1.index(n1.startIndex, offsetBy: 3)
            let range = start...stop
            let substring = n1[range]
            n1 = String(substring)
        }
        if n2.count > 3 {
            let start = n2.index(n2.startIndex, offsetBy: 0)
            let stop = n2.index(n2.startIndex, offsetBy: 3)
            let range = start...stop
            let substring = n2[range]
            n2 = String(substring)
        }
        if n3.count > 4 {
            let start = n3.index(n3.startIndex, offsetBy: 0)
            let stop = n3.index(n3.startIndex, offsetBy: 4)
            let range = start...stop
            let substring = n3[range]
            n3 = String(substring)
        }
        return n1+n2+n3
   }
    
    public static func fmtphone(area:String, exchange:String, number:String) -> String {
        let xa = FormattingService.rjf(base: area, len: 3, zeroFill: true)
        let xe = FormattingService.rjf(base: exchange, len: 3, zeroFill: true)
        let xn = FormattingService.rjf(base: number, len: 4, zeroFill: true)
        return xa + "-" + xe + "-" + xn
    }
    
    public static func deComposePhone(inpphone:String) -> [String] {
        if inpphone == "" { return ["", "", ""] }
        let trimmedPhone = inpphone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPhone == "" { return ["", "", ""] }

        let pieces = trimmedPhone.components(separatedBy: "-")
        if pieces.count == 3 { return pieces }
        if pieces.count == 2 { return [""] + pieces }
        if pieces.count == 1 {
            if trimmedPhone.count == 10 {
                let areaStart = trimmedPhone.index(trimmedPhone.startIndex, offsetBy: 0)
                let areaStop = trimmedPhone.index(trimmedPhone.startIndex, offsetBy: 2)
                let areaRange = areaStart...areaStop
                let exchangeStart = trimmedPhone.index(trimmedPhone.startIndex, offsetBy: 3)
                let exchangeStop = trimmedPhone.index(trimmedPhone.startIndex, offsetBy: 5)
                let exchangeRange = exchangeStart...exchangeStop
                let numberStart = trimmedPhone.index(trimmedPhone.startIndex, offsetBy: 6)
                let numberStop = trimmedPhone.index(trimmedPhone.startIndex, offsetBy: 9)
                let numberRange = numberStart...numberStop
                let chunkList:[String] = [String(trimmedPhone[areaRange]), String(trimmedPhone[exchangeRange]), String(trimmedPhone[numberRange])]
                return chunkList
            }
        }
        return(["999","999","9999"])
    }
}
