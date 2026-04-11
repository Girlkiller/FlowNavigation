//
//  File.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/4/11.
//

import Foundation
import FlowNavigationTypes

public enum NavigationAction {

    case push(RouteID, NavigationScope = .automatic)
    case pop(NavigationScope = .automatic)
    case popToRoot(NavigationScope = .automatic)

    case present(RouteID, PresentStyle = .fullScreen(transparent: false), initialStack: [RouteID]? = nil)
    case dismiss(RouteID)

    case sequence([NavigationAction])

    case replaceAll(with: RouteID, style: PresentStyle = .fullScreen(transparent: false))

    case replaceTop(RouteID, NavigationScope = .automatic)

    case dismissAndPush(
        dismissID: RouteID,
        pushID: RouteID,
        scope: NavigationScope = .automatic
    )
    
    case dismissAndPresent(
        dismissID: RouteID,
        presentID: RouteID,
        style: PresentStyle = .fullScreen(transparent: false),
        initialStack: [RouteID]? = nil
    )

    case navigate(url: URL, style: NavigationStyle = .push, scope: NavigationScope = .automatic)
}

extension NavigationAction: Equatable {

    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {

        switch (lhs, rhs) {

            // MARK: - push
        case let (.push(lid, lscope), .push(rid, rscope)):
            return lid == rid && lscope == rscope

            // MARK: - pop
        case let (.pop(lscope), .pop(rscope)):
            return lscope == rscope

            // MARK: - popToRoot
        case let (.popToRoot(lscope), .popToRoot(rscope)):
            return lscope == rscope

            // MARK: - present
        case let (.present(lid, lstyle, lstack),
                  .present(rid, rstyle, rstack)):
            return lid == rid
            && lstyle == rstyle
            && lstack == rstack

            // MARK: - dismiss
        case let (.dismiss(lid), .dismiss(rid)):
            return lid == rid

            // MARK: - sequence
        case let (.sequence(la), .sequence(ra)):
            return la == ra

            // MARK: - replaceAll
        case let (.replaceAll(lid, lstyle),
                  .replaceAll(rid, rstyle)):
            return lid == rid && lstyle == rstyle

            // MARK: - popAndPush
        case let (.replaceTop(lid, lscope),
                  .replaceTop(rid, rscope)):
            return lid == rid && lscope == rscope

        case let (.dismissAndPush(ld, lp, scope: lscope),
                  .dismissAndPush(rd, rp, scope: rscope)):
            return ld == rd && lp == rp && lscope == rscope
            
            // MARK: - dismissAndPresent
        case let (.dismissAndPresent(ld, lp, lstyle, lstack),
                  .dismissAndPresent(rd, rp, rstyle, rstack)):
            return ld == rd && lp == rp && lstyle == rstyle && lstack == rstack

        case let (.navigate(lurl, lstyle, lscope),
                  .navigate(rurl, rstyle, rscope)):
            return lurl == rurl && lstyle == rstyle && lscope == rscope

        default:
            return false
        }
    }
}
