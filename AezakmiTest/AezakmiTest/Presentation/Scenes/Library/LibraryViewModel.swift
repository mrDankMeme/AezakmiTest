
//
//  LibraryViewModel.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/22/25.
//

import Foundation
import Combine

final class LibraryViewModel: ObservableObject {
    @Published var docs: [Document] = []
    private var bag = Set<AnyCancellable>()
    private var repo: DocumentRepositoryProtocol
    
    init(repo: DocumentRepositoryProtocol) {
        self.repo = repo
        repo.list()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.docs = $0
            }
            .store(in: &bag)
    }
    
    func delete(_ id: UUID) { try? repo.delete(id: id)}
    func shareURL(_ id: UUID) -> URL? { try? repo.shareURL(for: id)}
}
