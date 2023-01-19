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

import Combine
import SwiftUI

typealias PollHistoryViewModelType = StateStoreViewModel<PollHistoryViewState, PollHistoryViewAction>

final class PollHistoryViewModel: PollHistoryViewModelType, PollHistoryViewModelProtocol {
    private let pollService: PollHistoryServiceProtocol
    private var polls: [TimelinePollDetails]?
    private var subcriptions: Set<AnyCancellable> = .init()
    
    var completion: ((PollHistoryViewModelResult) -> Void)?

    init(mode: PollHistoryMode, pollService: PollHistoryServiceProtocol) {
        self.pollService = pollService
        super.init(initialViewState: PollHistoryViewState(mode: mode))
    }

    // MARK: - Public

    override func process(viewAction: PollHistoryViewAction) {
        switch viewAction {
        case .viewAppeared:
            setupUpdateSubscriptions()
            fetchFirstBatch()
        case .segmentDidChange:
            updateViewState()
        case .showPollDetail(let poll):
            completion?(.showPollDetail(poll: poll))
        }
    }
}

private extension PollHistoryViewModel {
    func fetchFirstBatch() {
        state.isLoading = true
        
        pollService
            .next()
            .collect()
            .sink { [weak self] _ in
                #warning("Handle errors")
                self?.state.isLoading = false
            } receiveValue: { [weak self] polls in
                self?.polls = polls
                self?.updateViewState()
            }
            .store(in: &subcriptions)
    }
    
    func setupUpdateSubscriptions() {
        subcriptions.removeAll()
        
        pollService
            .updates
            .sink { [weak self] detail in
                self?.updatePolls(with: detail)
                self?.updateViewState()
            }
            .store(in: &subcriptions)
        
        pollService
            .pollErrors
            .sink { detail in
                #warning("Handle errors")
            }
            .store(in: &subcriptions)
    }
    
    func updatePolls(with poll: TimelinePollDetails) {
        guard let pollIndex = polls?.firstIndex(where: { $0.id == poll.id }) else {
            return
        }
            
        polls?[pollIndex] = poll
    }
    
    func updateViewState() {
        let renderedPolls: [TimelinePollDetails]?
        
        switch context.mode {
        case .active:
            renderedPolls = polls?.filter { $0.closed == false }
        case .past:
            renderedPolls = polls?.filter { $0.closed == true }
        }
        
        state.polls = renderedPolls?.sorted(by: { $0.startDate > $1.startDate })
    }
}
