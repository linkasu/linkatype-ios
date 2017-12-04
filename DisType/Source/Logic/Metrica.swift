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
//  Metrica.swift
//  DisType
//
//  Created by Mike Kholomeev on 12/4/17.
//

import Foundation
import YandexMobileMetrica

class Metrica {
    
    init() {
        YMMYandexMetrica.activate(withApiKey: "74b3edb9-a12c-4ec6-96e2-817e75e03941")
    }
    
    func saidEvent() {
        YMMYandexMetrica.reportEvent("said", onFailure: nil)
    }
    
    func categoryCreateEvent() {
        YMMYandexMetrica.reportEvent("create category", onFailure: nil)
    }
    
    func messageCreateEvent() {
        YMMYandexMetrica.reportEvent("create statement", onFailure: nil)
    }
    
    func categoryChangeEvent() {
        YMMYandexMetrica.reportEvent("change category", onFailure: nil)
    }
    
    func changeSayingAfterWordValueEvent() {
        YMMYandexMetrica.reportEvent("say after word status", onFailure: nil)
    }
}
