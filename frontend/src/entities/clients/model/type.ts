export type ClientListItem = {
  id: number
  fullName: string
  email?: string
  phone?: string
  type: 'BUYER' | 'SELLER'
  notes?: string
}
