//  Copyright © 2021 - present Julian Gerhards
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  GitHub https://github.com/knoggl/CleanUI
//

import SwiftUI
import Combine

extension CLIcon.Offset {
    
    /// Converts the ``CLIcon.Offset`` to a `CGSize`
    /// - Returns: The offset as `CGSize`
    func toCGSize() -> CGSize {
        switch self {
        case .leading(let of):
            return CGSize(width: of, height: 0)
        case .trailing(let of):
            return CGSize(width: -of, height: 0)
        case .bottom(let of):
            return CGSize(width: 0, height: -of)
        case .top(let of):
            return CGSize(width: 0, height: of)
        }
    }
}
