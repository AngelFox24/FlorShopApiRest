import Vapor
import FluentKit
import FlorShopDTOs
import FlorShopValkey

struct BillingStreamHandler: StreamHandler {
    let streamName: ValkeyStream
    let groupName: String
    let consumerName: String
    let app: Application
    let billingProvider: FlorShopBillingProvider
    func handler(fields: [String: String]) async -> Bool {
        guard let eventType = ValkeyEventType.Billing(rawValue: fields["type"] ?? "") else {
            app.logger.info("Auth recibió evento desconocido")
            return false
        }
        let payload = fields["payload"] ?? "{}"
        app.logger.info("Auth recibió evento: \(eventType) payload: \(payload)")
        do {
            let result = try await app.db.transaction { tx -> Bool in
                switch eventType {
                case .changeSuscription:
                    return try await self.changeSuscription(payload: payload, on: tx)
                case .changePlan:
                    return true
                }
            }
            return result
        } catch {
            app.logger.info("Evento salio error")
            return false
        }
    }
    //MARK: Change Suscription
    private func changeSuscription(payload: String, on tx: any Database) async throws -> Bool {
        guard let data = payload.data(using: .utf8) else {
            app.logger.error("No se pudo convertir el payload a data")
            return false
        }
        let dto = try app.myJSONDecoder.decode(SuscriptionServerDTO.self, from: data)
        var plan = try await Plan.getPlan(planCic: dto.planCic, on: tx)
        //Si el plan existe pero los features estan desactualizados no se van a actualizar, tendria que hacer un peticion a billing y no es eficiente.
        //En changePlan ya se hara esos cambios
        if plan == nil {
            print("[changeSuscription] El plan no existe en local")
            let planDTO: PlanDTO = try await self.billingProvider.getPlanByCic(planCic: dto.planCic, app: app)
            let newPlan = Plan(
                planCic: planDTO.planCic,
                name: planDTO.name,
                price: planDTO.price.cents,
                currency: planDTO.currency,
                interval: planDTO.interval,
                isActive: planDTO.isActive
            )
            try await newPlan.save(on: tx)
            for feature in planDTO.limits {
                let newPlanFeature = PlanFeature(
                    planId: newPlan.id!,
                    key: feature.key,
                    label: feature.label,
                    isWebVisible: feature.isWebVisible,
                    valueInt: feature.valueInt,
                    valueString: feature.valueString,
                    valueBool: feature.valueBool
                )
                print("[changeSuscription] Creando planFeature: \(feature.key)")
                try await newPlanFeature.save(on: tx)
            }
            plan = newPlan
        }
        guard let planId = plan?.id else {
            app.logger.error("No se pudo generar el id del plan")
            throw Abort(.internalServerError)
        }
        guard let company = try await Company.findCompany(companyCic: dto.companyCic, on: tx) else {
            app.logger.error("Company no existe con el companyCic: \(dto.companyCic)")
            throw Abort(.internalServerError)
        }
        if let suscription = try await Suscription.find(suscriptionCic: dto.suscriptionCic, on: tx) {
            //Update suscription
            print("[changeSuscription] Actualizando nueva suscripcion companyCic: \(dto.companyCic)")
            suscription.endAt = dto.suscriptionExpireAt
            suscription.status = dto.status
            suscription.$plan.id = planId
            try await suscription.save(on: tx)
        } else {
            //New Suscription
            print("[changeSuscription] Creando nueva suscripcion companyCic: \(dto.companyCic)")
            let newSuscription = Suscription(
                suscriptionCic: dto.suscriptionCic,
                planID: planId,
                companyCic: dto.companyCic,
                status: .active,
                startAt: Date(),
                endAt: dto.suscriptionExpireAt,
                cancelAtPeriodEnd: true
            )
            try await newSuscription.save(on: tx)
            guard let suscriptionId = newSuscription.id else {
                app.logger.error("No se pudo generar el id de newSuscription")
                throw Abort(.internalServerError)
            }
            company.$subscription.id = suscriptionId
            try await company.save(on: tx)
        }
        return true
    }
}
