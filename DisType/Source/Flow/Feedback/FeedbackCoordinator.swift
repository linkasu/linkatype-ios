/*-
 * Copyright © 2016  Alex Makushkin
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
//
//  FeedbackCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 12/12/17.
//

import Foundation
import UIKit

class FeedbackCoordinator: BaseCoordinator, Coordinator, CoordinatorOutput, FeedbackCoordinatorDelegate {

    var finishFlow: ((Any) -> Void)?
    
    fileprivate let router: Router
    fileprivate let assembly:AssemblyCoordinator
    fileprivate let screenAssembly: AssemblyScreen
    fileprivate let feedback: Feedback
    fileprivate let sourceView: UIView?

    init(_ router: Router, assembly: AssemblyCoordinator, screenAssembly: AssemblyScreen, feedback: Feedback, sourceView: UIView) {
        self.router = router
        self.assembly = assembly
        self.screenAssembly = screenAssembly
        self.feedback = feedback
        self.sourceView = sourceView
    }

    fileprivate lazy var feedbackVC: FeedbackScreen = {
        let vc = self.screenAssembly.feedbackScreen(delegate:self)
        return vc
    }()

    func start() {
        router.presentModaly(feedbackVC, sourceView:sourceView)
    }
    
    // MARK: - FeedbackCoordinatorDelegate
    internal func didSend(text: String, to email: String?) {
        guard let _email = email else { return }
        feedback.send(text:text, to:_email)
//        feedbackVC.dismiss(animated: true, completion: nil)
        finishFlow?(true)
    }
    
    internal func didCloseScreen() {
        finishFlow?(false)
    }
}
