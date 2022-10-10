//
//  LogsView.swift
//  vexl
//
//  Created by Adam Salih on 06.10.2022.
//

import SwiftUI

struct LogsView: View {

    @ObservedObject var viewModel: LogsViewModel

    @State private var isAnimatingButton: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.padding) {
            HStack(alignment: .center, spacing: Appearance.GridGuide.padding) {
                Button {
                    viewModel.send(action: .dismissTap)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.white)
                        .frame(size: Appearance.GridGuide.baseButtonSize)
                        .background(Appearance.Colors.gray1)
                        .cornerRadius(Appearance.GridGuide.point)
                }
                HStack(alignment: .center, spacing: .zero) {
                    Text(L.logsTitle())
                        .textStyle(.h2)
                        .foregroundColor(Appearance.Colors.whiteText)

                    Spacer()

                    Toggle("", isOn: $viewModel.isCollectingEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Appearance.Colors.yellow100))
                }
            }
            .padding(.bottom, Appearance.GridGuide.point)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.logs) { log in
                            HStack(alignment: .top) {
                                Text(log.formattedDate)
                                    .textStyle(.description)
                                    .foregroundColor(Appearance.Colors.whiteText)
                                Text(log.message)
                                    .textStyle(.description)
                                    .foregroundColor(Appearance.Colors.gray4)
                                Spacer()
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .onChange(of: viewModel.lastLog) { lastLog in
                    proxy.scrollTo(lastLog.id, anchor: .bottom)
                }
                .onAppear {
                    proxy.scrollTo(viewModel.lastLog.id, anchor: .bottom)
                }
            }

            LargeSolidButton(
                title: isAnimatingButton ? L.logsTextCopiedClipboard() : L.logsButton(),
                iconImage: isAnimatingButton ? nil : Image(R.image.profile.copy.name),
                font: Appearance.TextStyle.paragraphBold.font.asFont,
                style: isAnimatingButton ? .custom(color: .success) : .main,
                isFullWidth: true,
                isEnabled: .constant(true),
                action: {
                    animateButton()
                    viewModel.action.send(.copyTap)
                }
            )
        }
        .padding(Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    func animateButton() {
        isAnimatingButton = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                isAnimatingButton = false
            }
        }
    }
}

#if DEBUG || DEVEL

struct LogsViewPreview: PreviewProvider {

    static var viewModel: LogsViewModel {
        let viewModel = LogsViewModel()
        let loremIpsum = "Lorem ipsum dolor sit amet, conse ctetuer adipiscing elit. Pellentesque arcu. Phasellus et lorem id felis nonummy placerat. Maecenas aliqueto."
        viewModel.logs = [
            Log(message: loremIpsum),
            Log(message: loremIpsum),
            Log(message: loremIpsum),
            Log(message: loremIpsum),
            Log(message: loremIpsum),
            Log(message: loremIpsum)
        ]
        return viewModel
    }

    static var previews: some View {
        LogsView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
