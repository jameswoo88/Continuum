//
//  SearchableRecord.swift
//  Continuum
//
//  Created by James Chun on 5/12/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
    
}//end of protocol
