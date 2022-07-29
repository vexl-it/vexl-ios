//
//  Aliases.swift
//  Pods
//
//  Created by Adam Salih on 05.02.2022.
//

import Combine

public typealias CoordinatingResult<T> = AnyPublisher<T, Never>
public typealias CoordinatingSubject<T> = PassthroughSubject<T, Never>
public typealias ActionSubject<T> = PassthroughSubject<T, Never>
public typealias Cancellables = Set<AnyCancellable>
