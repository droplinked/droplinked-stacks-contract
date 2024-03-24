import { Cl } from '@stacks/transactions'
import { describe, expect, it } from 'vitest'

import { Beneficiary, Issuer, ProductType } from './utils/base.droplinked'
import { createProduct_args } from './utils/operator.droplinked'
import { OperatorErrors } from './utils/errors'

const deployer = simnet.deployer
const droplinkedOperatorContract = deployer + '.droplinked-operator'

describe("'set-droplinked-admin' function", () => {
	it('should return (err u100) if sender is not admin', () => {
		const response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'set-droplinked-admin',
			[Cl.principal('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')],
			'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
		)

		expect(response.result).toBeErr(Cl.uint(100))
	})

	it('ensures current admin call function and change admin', () => {
		const response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'set-droplinked-admin',
			[Cl.principal('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')],
			'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
		)

		expect(response.result).toBeOk(Cl.bool(true))

		const adminResponse = simnet.callReadOnlyFn(
			droplinkedOperatorContract,
			'get-droplinked-admin',
			[],
			'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
		)

		expect(adminResponse.result).toBePrincipal(
			'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
		)
	})
})

describe("'set-droplinked-destination' function", () => {
	it('should return (err u100) if sender is not admin', () => {
		const response = simnet.callPublicFn(
			'droplinked-operator',
			'set-droplinked-destination',
			[Cl.principal('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')],
			'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
		)

		expect(response.result).toBeErr(Cl.uint(100))
	})

	it('ensures current admin call function and change destination', () => {
		const response = simnet.callPublicFn(
			'droplinked-operator',
			'set-droplinked-destination',
			[Cl.principal('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')],
			'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
		)

		expect(response.result).toBeOk(Cl.bool(true))

		const adminResponse = simnet.callReadOnlyFn(
			'droplinked-operator',
			'get-droplinked-destination',
			[],
			'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
		)

		expect(adminResponse.result).toBePrincipal(
			'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
		)
	})
})

describe("'create-product' function", () => {
	const producer = 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
	const uri = "{ description: 'droplinked-product uri' }"
	const price = 2500
	const amount = 20000
	const commission = 20
	const type = ProductType.DIGITAL
	const beneficiaries: Beneficiary[] = [
		{
			percentage: true,
			address: 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND',
			value: 5,
		},
		{
			percentage: true,
			address: 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC',
			value: 5,
		},
	]
	const issuer: Issuer = { address: producer, value: 200 }

	const args = createProduct_args(
		producer,
		uri,
		price,
		amount,
		commission,
		type,
		producer,
		producer,
		beneficiaries,
		issuer
	)

	it('should return (err u201) if sender is not producer', () => {
		const response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'create-product',
			args,
			'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP'
		)

		expect(response.result).toBeErr(OperatorErrors.PRODUCER_ONLY)
	})

	it('should return (err u300) if price is 0', () => {
		const invalidPrice_args = [...args]
		invalidPrice_args[2] = Cl.uint(0)

		const response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'create-product',
			invalidPrice_args,
			producer
		)

		expect(response.result).toBeErr(OperatorErrors.INVALID_PRICE)
	})

	it('should return (err u301) if commission > 100', () => {
		const invalidCommission_args = [...args]
		invalidCommission_args[4] = Cl.uint(201)

		const response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'create-product',
			invalidCommission_args,
			producer
		)

		expect(response.result).toBeErr(OperatorErrors.INVALID_COMMISSION)
	})

	it('should return (err u302) if type is not digital, print_on_demand or physical', () => {
		const invalidType_args = [...args]
		invalidType_args[5] = Cl.buffer(Buffer.from([0x11]))

		const response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'create-product',
			invalidType_args,
			producer
		)

		expect(response.result).toBeErr(OperatorErrors.INVALID_TYPE)
	})

	it('should return ok response if product type is digital', () => {
		const digitalProduct_args = [...args]
		digitalProduct_args[5] = Cl.buffer(Buffer.from([ProductType.DIGITAL]))

		let response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'create-product',
			digitalProduct_args,
			producer
		)

		expect(response.result).toBeOk(Cl.uint(1))
	})

	it('should return ok response if product is print_on_demand', () => {
		const digitalProduct_args = [...args]
		digitalProduct_args[5] = Cl.buffer(
			Buffer.from([ProductType.PRINT_ON_DEMAND])
		)

		let response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'create-product',
			digitalProduct_args,
			producer
		)

		expect(response.result).toBeOk(Cl.uint(1))
	})

	it('should return ok response if product is physical', () => {
		const digitalProduct_args = [...args]
		digitalProduct_args[5] = Cl.buffer(Buffer.from([ProductType.PHYSICAL]))

		let response = simnet.callPublicFn(
			droplinkedOperatorContract,
			'create-product',
			digitalProduct_args,
			producer
		)

		expect(response.result).toBeOk(Cl.uint(1))
	})
})
