//
//  String+Extension.swift
//  TaskManager
//
//  Created by Janaina A on 26/02/2025.
//

import Foundation

extension String {
    
    /// Here we are converting date string in one format to given output format
    func formatDate(inputFormat: dateFormat, outputFormat: dateFormat)-> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = inputFormat.rawValue
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = outputFormat.rawValue
        
        if let dateStr = dateFormatterGet.date(from: self) {
            return dateFormatterPrint.string(from: dateStr)
        } else {
            print("There was an error decoding the string")
            return self
        }
    }
}
