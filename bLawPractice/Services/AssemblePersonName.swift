//
//  AssemblePersonName.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import Foundation

struct AssemblePersonName {
    public static func assembleName(firstName:String, middleName:String, lastName:String, suffix:String) -> String {
        var workName:String = ""
        var trimName:String = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimSuffix:String = suffix.trimmingCharacters(in: .whitespacesAndNewlines)
        workName = workName + trimName
        if trimSuffix != "" && workName != "" {
            workName = workName + trimSuffix
        }
        trimName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimName != "" {
            if workName != "" {
                workName = workName + ", "
            }
            workName = workName + trimName
        }
        trimName = middleName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimName != "" {
            if workName != "" {
                workName = workName + " "
            }
            workName = workName + trimName
        }
        return workName
    }
}
