
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
    
    //Merge state
    @Published var mergingSource: Document? = nil
    @Published var errorMessage: String? = nil
  
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
    
    //MARK: - Merge
    var isMerging: Bool { mergingSource != nil }
    
    func beginMerge(from doc: Document) {
        mergingSource = doc
    }
    
    func cancelMerge() {
        mergingSource = nil
    }
    
    func selecTarget(_ target: Document) {
        guard let source = mergingSource, source.id != target.id else { return }
        do {
            _ = try repo.merge(source.id,
                               target.id,
                               name: "\(source.name)+\(target.name)")
            
        } catch {
            errorMessage = error.localizedDescription
            mergingSource = nil
        }
    }
}
