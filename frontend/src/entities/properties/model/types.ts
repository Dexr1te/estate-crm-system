export type PropertyType =
  | 'APARTMENT'
  | 'HOUSE'
  | 'COMMERCIAL'
  | 'LAND'
  | 'OFFICE'

export type PropertyStatus = 'AVAILABLE' | 'RESERVED' | 'SOLD'

export type Property = {
  id: number
  title: string
  description?: string | null
  type: PropertyType
  status: PropertyStatus
  address: string
  price: number
  city?: string | null
  areaSqm?: number | null
  rooms?: number | null
  floor?: number | null
  totalFloors?: number | null
  agentId?: number | null
  agentName?: string | null
}

export type PropertyCreateRequest = {
  title: string
  description?: string
  address: string
  city?: string
  type: PropertyType
  status?: PropertyStatus
  price: number
  areaSqm?: number
  rooms?: number
  floor?: number
  totalFloors?: number
  agentId?: number
}

export type PropertyFilters = {
  status?: PropertyStatus
  type?: PropertyType
  city?: string
  minPrice?: number
  maxPrice?: number
  search?: string
}
