//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//
import Adyen
import AdyenActions
import AdyenCard
import AdyenDropIn
import AdyenComponents
import UIKit

extension PaymentsController {

    // MARK: - DropIn Component

    internal func presentDropInComponent() {
        guard let paymentMethods = paymentMethods else { return }
        let configuration = DropInComponent.PaymentMethodsConfiguration(clientKey: Configuration.clientKey)
        configuration.applePay.merchantIdentifier = Configuration.applePayMerchantIdentifier
        configuration.applePay.summaryItems = Configuration.applePaySummaryItems
        configuration.environment = environment
        configuration.localizationParameters = nil
        configuration.payment = payment

        let dropInComponentStyle = DropInComponent.Style()
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        paymentMethodsConfiguration: configuration,
                                        style: dropInComponentStyle,
                                        title: Configuration.appName)
        component.delegate = self
        currentComponent = component

        presenter?.present(viewController: component.viewController, completion: nil)
    }

    private func handle(_ action: Action) {
        guard paymentInProgress else { return }
        (currentComponent as? DropInComponent)?.handle(action)
    }
}

extension PaymentsController: DropInComponentDelegate {

    internal func didSubmit(_ data: PaymentComponentData, from component: DropInComponent) {
        performPayment(with: data)
        paymentInProgress = true
    }

    internal func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        performPaymentDetails(with: data)
    }

    internal func didFail(with error: Error, from component: DropInComponent) {
        paymentInProgress = false
        finish(with: error)
    }

    internal func didCancel(component: PresentableComponent, from dropInComponent: DropInComponent) {
        // Handle the event when the user closes a PresentableComponent.
        print("User did close: \(component)")
    }

}