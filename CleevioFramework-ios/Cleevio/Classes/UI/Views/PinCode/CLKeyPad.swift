//
//  CLKeyPad.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 1/11/21.
//

import SwiftUI
import Combine

public struct CLKeyPad: View {
    var keyTap: PassthroughSubject<Int, Never>
    var deleteTap: PassthroughSubject<Void, Never>

    public init(keyTap: PassthroughSubject<Int, Never>, deleteTap: PassthroughSubject<Void, Never>) {
        self.keyTap = keyTap
        self.deleteTap = deleteTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            KeyPadRow(rowType: .first(keyTap: keyTap))
            KeyPadRow(rowType: .second(keyTap: keyTap))
            KeyPadRow(rowType: .third(keyTap: keyTap))
            KeyPadRow(rowType: .fourth(keyTap: keyTap, deleteTap: deleteTap))
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct CLKeyPad_Previews: PreviewProvider {
    static var previews: some View {
        CLKeyPad(keyTap: PassthroughSubject<Int, Never>(), deleteTap: PassthroughSubject<Void, Never>())
    }
}
#endif

enum RowType {
    case first(keyTap: PassthroughSubject<Int, Never>)
    case second(keyTap: PassthroughSubject<Int, Never>)
    case third(keyTap: PassthroughSubject<Int, Never>)
    case fourth(keyTap: PassthroughSubject<Int, Never>, deleteTap: PassthroughSubject<Void, Never>)
}

struct KeyPadRow: View {
    var rowType: RowType

    var body: some View {
        GeometryReader { geometry in
            let buttonWidth = geometry.size.width / 3
            HStack(spacing: 0) {
                switch rowType {
                case .first(let keyTap):
                    ForEach(1 ... 3, id: \.self) { index in
                        Button {
                            keyTap.send(index)
                        } label: {
                            Text("\(index)")
                                .font(.system(size: 36, weight: .regular, design: .default))
                                .foregroundColor(.black)
                        }
                        .frame(width: buttonWidth)
                    }
                case .second(let keyTap):
                    ForEach(4 ... 6, id: \.self) { index in
                        Button {
                            keyTap.send(index)
                        } label: {
                            Text("\(index)")
                                .font(.system(size: 36, weight: .regular, design: .default))
                                .foregroundColor(.black)
                        }
                        .frame(width: buttonWidth)
                    }
                case .third(let keyTap):
                    ForEach(7 ... 9, id: \.self) { index in
                        Button {
                            keyTap.send(index)
                        } label: {
                            Text("\(index)")
                                .font(.system(size: 36, weight: .regular, design: .default))
                                .foregroundColor(.black)
                        }
                        .frame(width: buttonWidth)
                    }
                case .fourth(let keyTap, let deleteTap):
                    Text("")
                        .frame(width: buttonWidth)
                    Button {
                        keyTap.send(0)
                    } label: {
                        Text("0")
                            .font(.system(size: 36, weight: .regular, design: .default))
                            .foregroundColor(.black)
                    }
                    .frame(width: buttonWidth)
                    Button {
                        deleteTap.send(())
                    } label: {
                        Image("icBack")
                    }
                    .frame(width: buttonWidth)
                }
            }
        }
    }
}
