//
//  GetSubjectStatusAsAdmin.swift
//
//
//  Created by Christopher Jr Riley on 2024-03-01.
//

import Foundation

extension ATProtoAdmin {

    /// Gets the status of a subject as an administrator.
    /// 
    /// - Important: This is an administrator task and as such, regular users won't be able to
    /// access this; if they attempt to do so, an error will occur.
    ///
    /// - Note: According to the AT Protocol specifications: "Get the service-specific admin
    /// status of a subject (account, record, or blob)."
    ///
    /// - SeeAlso: This is based on the [`com.atproto.admin.getSubjectStatus`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/admin/getSubjectStatus.json
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID) of the subject.
    ///   - subjectURI: The URI of the subject.
    ///   - subjectBlobCIDHash: The CID hash of the blob for the subject.
    /// - Returns: The status of a subject.
    ///
    /// - Throws: An ``ATProtoError``-conforming error type, depending on the issue. Go to
    /// ``ATAPIError`` and ``ATRequestPrepareError`` for more details.
    public func getSubjectStatus(
        _ did: String,
        subjectURI: String,
        subjectBlobCIDHash: String
    ) async throws -> ComAtprotoLexicon.Admin.GetSubjectStatusOutput {
        guard session != nil,
              let accessToken = session?.accessToken else {
            throw ATRequestPrepareError.missingActiveSession
        }

        guard let sessionURL = session?.pdsURL,
              let requestURL = URL(string: "\(sessionURL)/xrpc/com.atproto.admin.getSubjectStatus") else {
            throw ATRequestPrepareError.invalidRequestURL
        }

        let queryItems = [
            ("did", did),
            ("uri", subjectURI),
            ("blob", subjectBlobCIDHash)
        ]

        let queryURL: URL

        do {
            queryURL = try APIClientService.setQueryItems(
                for: requestURL,
                with: queryItems
            )

            let request = APIClientService.createRequest(
                forRequest: queryURL,
                andMethod: .get,
                acceptValue: "application/json",
                contentTypeValue: nil,
                authorizationValue: "Bearer \(accessToken)"
            )
            let response = try await APIClientService.shared.sendRequest(
                request,
                decodeTo: ComAtprotoLexicon.Admin.GetSubjectStatusOutput.self
            )

            return response
        } catch {
            throw error
        }
    }
}
