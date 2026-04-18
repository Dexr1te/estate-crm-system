export type Property = {
  id: number
  title: string
  description: string
  type: string
  status: 'AVAILABLE' | 'SOLD' | 'RESERVED'
  address: string
  price: number
  city?: string
}
