import { Cl } from '@stacks/transactions'

import { Beneficiary, Issuer, ProductType } from './base.droplinked'

export const createProduct_args = (
	producer: string,
	uri: string,
	price: number,
	amount: number,
	commission: number,
	type: ProductType,
	recipient: string,
	destination: string,
	beneficiaries: Beneficiary[],
	issuer: Issuer
) => {
	return [
		Cl.principal(producer),
		Cl.stringAscii(uri),
		Cl.uint(price),
		Cl.uint(amount),
		Cl.uint(commission),
		Cl.buffer(Buffer.from([type])),
		Cl.principal(recipient),
		Cl.principal(destination),
		Cl.list(
			beneficiaries.map((beneficiary) =>
				Cl.tuple({
					percentage: Cl.bool(beneficiary.percentage),
					address: Cl.principal(beneficiary.address),
					value: Cl.uint(beneficiary.value),
				})
			)
		),
		Cl.tuple({
			address: Cl.principal(issuer.address),
			value: Cl.uint(issuer.value),
		}),
	]
}
