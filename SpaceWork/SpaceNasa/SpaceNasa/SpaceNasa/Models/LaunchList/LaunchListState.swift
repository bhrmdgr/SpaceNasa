//
//  LaunchListState.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 10.10.2025.
//

import Foundation

struct LaunchListState: Equatable {
    var isLoading = false
    var items: [LaunchListItem] = []
    var errorMessage: String?
    var shouldShowEmptyAlert = false
}
