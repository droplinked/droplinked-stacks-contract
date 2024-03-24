import { Cl } from '@stacks/transactions'

export const BaseErrors = {
	DROPLINKED_OPERATOR_ONLY: Cl.uint(100),
}

export const OperatorErrors = {
	PUBLISHER_ONLY: Cl.uint(201),
	PRODUCER_ONLY: Cl.uint(201),
	INVALID_PRICE: Cl.uint(300),
	INVALID_COMMISSION: Cl.uint(301),
	INVALID_TYPE: Cl.uint(302),
}
