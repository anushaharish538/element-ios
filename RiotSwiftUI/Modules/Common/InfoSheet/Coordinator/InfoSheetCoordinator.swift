//
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CommonKit
import SwiftUI

struct InfoSheetCoordinatorParameters {
    let title: String
    let description: String
    let action: InfoSheet.Action
}

final class InfoSheetCoordinator: Coordinator, Presentable {
    private let parameters: InfoSheetCoordinatorParameters
    private let infoSheetHostingController: UIViewController
    private var infoSheetViewModel: InfoSheetViewModelProtocol

    // Must be used only internally
    var childCoordinators: [Coordinator] = []
    var completion: ((InfoSheetViewModelResult) -> Void)?
    
    init(parameters: InfoSheetCoordinatorParameters) {
        self.parameters = parameters
        
        let viewModel = InfoSheetViewModel(title: parameters.title, description: parameters.description, action: parameters.action)
        let view = InfoSheet(viewModel: viewModel.context)
        infoSheetViewModel = viewModel
        let controller = VectorHostingController(rootView: view)
        controller.bottomSheetPreferences = .init()
        infoSheetHostingController = controller
    }
    
    // MARK: - Public
    
    func start() {
        MXLog.debug("[InfoSheetCoordinator] did start.")
        infoSheetViewModel.completion = { [weak self] result in
            guard let self = self else { return }
            MXLog.debug("[InfoSheetCoordinator] InfoSheetViewModel did complete with result: \(result).")
            self.completion?(result)
        }
    }
    
    func toPresentable() -> UIViewController {
        infoSheetHostingController
    }
}
