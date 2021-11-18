//
//  EmailModel.swift
//  UITableView
//
//  Created by Emil Atanasov on 11/11/17.
//  Copyright © 2017 SwiftFMI. All rights reserved.
//

import Foundation

struct Email {
    var sender = "Sender"
    var subject = "Subject"
    var summary = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse et tempor tortor. Nam dictum sit amet metus et condimentum. Integer malesuada lacus congue fermentum feugiat. Maecenas id libero eleifend, iaculis lectus in, iaculis orci. Duis elementum interdum mattis. Pellentesque commodo lobortis leo, mattis viverra metus suscipit sit amet. Ut mollis posuere nisi eget elementum."
    var date = Date()
}

extension Date {
    
    static func getDate(year: Int, month:Int, day:Int, hour:Int, minute:Int) -> Date {
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    //dateComponents.timeZone = TimeZone(abbreviation: "UTC")
    dateComponents.hour = hour
    dateComponents.minute = minute
    
    let userCalendar = Calendar.current // user calendar
    return userCalendar.date(from: dateComponents)!
    }
    
}

func randomItem<T>(from:[T]) -> T {
    let index = Int(arc4random_uniform(UInt32(from.count)))
    return from[index]
}


extension Email {
   static func getMockEmails(items:Int = 10) -> [Email] {
        var emails:[Email] = []
        
        let summary = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse et tempor tortor. Nam dictum sit amet metus et condimentum. Integer malesuada lacus congue fermentum feugiat. Maecenas id libero eleifend, iaculis lectus in, iaculis orci. Duis elementum interdum mattis. Pellentesque commodo lobortis leo, mattis viverra metus suscipit sit amet. Ut mollis posuere nisi eget elementum."
        
        //senders
        let senders = ["Ivan Ivanov", "Georgi Petrov", "John Smith", "Peter Pavlovich", "Colin Stoyanov"]
        
        let subjects = ["Summer vacation", "Going out", "Swift course", "Movie night", "Project X", "New iPhone", "Baseball game"]
        
        let dates = [Date.getDate(year: 2017, month: 11, day: 11, hour: 11, minute: 44),
                    Date.getDate(year: 2017, month: 11, day: 10, hour: 11, minute: 41),
                    Date.getDate(year: 2017, month: 11, day: 8, hour: 10, minute: 44),
                    Date.getDate(year: 2017, month: 8, day: 11, hour: 11, minute: 42),
                    Date.getDate(year: 2017, month: 10, day: 11, hour: 16, minute: 44),
                    Date.getDate(year: 2017, month: 11, day: 1, hour: 11, minute: 4),
                    Date.getDate(year: 2017, month: 10, day: 3, hour: 21, minute: 34),
                    Date.getDate(year: 2017, month: 9, day: 11, hour: 7, minute: 44),
                    Date.getDate(year: 2017, month: 10, day: 21, hour: 11, minute: 44),
                    Date.getDate(year: 2017, month: 11, day: 7, hour: 10, minute: 24)
                    ]
        
        for _ in 1...items {
            emails.append(Email(sender: randomItem(from: senders), subject: randomItem(from: subjects), summary: summary, date: randomItem(from: dates)))
        }
        
        emails.sort { (first, second) -> Bool in
            first.date.compare(second.date) == ComparisonResult.orderedDescending
        }
        
        return emails
    }
}


