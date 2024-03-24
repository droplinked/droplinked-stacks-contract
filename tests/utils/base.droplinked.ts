import { Cl } from '@stacks/transactions'

export enum ProductType {
	DIGITAL = 0x00,
	PRINT_ON_DEMAND = 0x01,
	PHYSICAL = 0x02,
}

export type Beneficiary = {
	percentage: boolean
	address: string
	value: number
}

export type Issuer = {
	address: string
	value: number
}

export const insertProduct_args = (
	product_id: number,
	producer: string,
	price: number,
	commission: number,
	type: ProductType,
	destination: string,
	beneficiaries: Beneficiary[],
	issuer: Issuer
) => {
	return [
		Cl.uint(product_id),
		Cl.principal(producer),
		Cl.uint(price),
		Cl.uint(commission),
		Cl.buffer(Buffer.from([type])),
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
