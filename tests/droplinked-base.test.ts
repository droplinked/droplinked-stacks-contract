import { Cl } from '@stacks/transactions'
import { describe, expect, it } from 'vitest'

import {
	Beneficiary,
	Issuer,
	ProductType,
	insertProduct_args,
} from './utils/base.droplinked'
import { DroplinkedOperatorOnly } from './utils/errors'

const deployer = simnet.deployer
const droplinkedBase = deployer + '.droplinked-base'

describe("'insert-product' function", () => {
	const id = 1
	const producer = 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'
	const price = 2500
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

	const args = insertProduct_args(
		id,
		producer,
		price,
		commission,
		type,
		producer,
		beneficiaries,
		issuer
	)

	it('must return (err u100) if sender is not droplinked-operator', () => {
		const response = simnet.callPublicFn(
			droplinkedBase,
			'insert-product',
			args,
			producer
		)

		expect(response.result).toBeErr(DroplinkedOperatorOnly)
	})
})
