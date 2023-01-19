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

import SwiftUI

struct PollHistoryDetail: View {
    // MARK: - Properties
    
    // MARK: Private
    
    @Environment(\.theme) private var theme: ThemeSwiftUI
    
    // MARK: Public
    
    @ObservedObject var viewModel: PollHistoryDetailViewModel.Context
    
    var body: some View {
        let poll = viewModel.viewState.poll
        
        VStack(alignment: .leading, spacing: 16.0) {
            if poll.representsPollEndedEvent {
                Text(VectorL10n.pollTimelineEndedText)
                    .font(theme.fonts.footnote)
                    .foregroundColor(theme.colors.tertiaryContent)
            }
            
            Text(poll.question)
                .font(theme.fonts.bodySB)
                .foregroundColor(theme.colors.primaryContent) +
                Text(editedText)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.secondaryContent)
            
            VStack(spacing: 24.0) {
                ForEach(poll.answerOptions) { answerOption in
                    PollHistoryDetailAnswerOptionButton(poll: poll, answerOption: answerOption) {
                        viewModel.send(viewAction: .selectAnswerOptionWithIdentifier(answerOption.id))
                    }
                }
            }
            .disabled(poll.closed)
            .fixedSize(horizontal: false, vertical: true)
            
            Text(totalVotesString)
                .lineLimit(2)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.tertiaryContent)
        }
        .padding([.horizontal], 16)
        .padding([.top, .bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(navigationTitle)
//        .alert(item: $viewModel.alertInfo) { info in
//            info.alert
//        }
    }
    
    private var navigationTitle: String {
        let poll = viewModel.viewState.poll
        if poll.closed {
            return VectorL10n.pollHistoryPastSegmentTitle
        } else {
            return VectorL10n.pollHistoryActiveSegmentTitle
        }
    }
    
    private var totalVotesString: String {
        let poll = viewModel.viewState.poll
        
        if poll.hasDecryptionError, poll.totalAnswerCount > 0 {
            return VectorL10n.pollTimelineDecryptionError
        }
        
        if poll.closed {
            if poll.totalAnswerCount == 1 {
                return VectorL10n.pollTimelineTotalFinalResultsOneVote
            } else {
                return VectorL10n.pollTimelineTotalFinalResults(Int(poll.totalAnswerCount))
            }
        }
        
        switch poll.totalAnswerCount {
        case 0:
            return VectorL10n.pollTimelineTotalNoVotes
        case 1:
            return (poll.hasCurrentUserVoted || poll.type == .undisclosed ?
                VectorL10n.pollTimelineTotalOneVote :
                VectorL10n.pollTimelineTotalOneVoteNotVoted)
        default:
            return (poll.hasCurrentUserVoted || poll.type == .undisclosed ?
                VectorL10n.pollTimelineTotalVotes(Int(poll.totalAnswerCount)) :
                VectorL10n.pollTimelineTotalVotesNotVoted(Int(poll.totalAnswerCount)))
        }
    }
    
    private var editedText: String {
        viewModel.viewState.poll.hasBeenEdited ? " \(VectorL10n.eventFormatterMessageEditedMention)" : ""
    }
}

// MARK: - Previews

struct PollHistoryDetail_Previews: PreviewProvider {
    static let stateRenderer = MockPollHistoryDetailScreenState.stateRenderer
    static var previews: some View {
        stateRenderer.screenGroup()
    }
}
