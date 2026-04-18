# Estate CRM - Business Logic & Context

## 📌 Project Vision

**Estate CRM** is a real estate Customer Relationship Management system designed for real estate agents and administrators to manage properties, clients, deals, and meetings in a streamlined workflow.

**Target Users**:

- Real estate agents (AGENT role)
- Administrators (ADMIN role)

**Geographic Context**: Kazakhstan (local currency, terminology)

---

## 🎯 Core Business Concepts

### 1. **The Sales Funnel**

Estate CRM manages the real estate sales/buying process through these stages:

```
CLIENT ACQUISITION
    ↓
PROPERTY MATCHING
    ↓
NEGOTIATION (Deal)
    ↓
DEAL CLOSURE
    ↓
FOLLOW-UP (Meetings/Documents)
```

### 2. **The Four Main Entities**

#### **🧑 Client (Клиент)**

A person who either **buys (BUYER)** or **sells (SELLER)** property.

**Client Profile**:

- Full name, email, phone
- Type: BUYER or SELLER
- Associated deals and meetings
- Budget (for buyers)
- Next meeting scheduled
- Last contact date

**Why it matters**: Agents track clients over time, managing relationships throughout the sales process.

---

#### **🏠 Property (Недвижимость)**

A real estate object (apartment, house, commercial space, land, office).

**Property Attributes**:

- Title and address
- Type: APARTMENT, HOUSE, COMMERCIAL, LAND, OFFICE
- Status: AVAILABLE, RESERVED, or SOLD
- Photos and description
- Price

**Why it matters**: Properties are the core asset being sold/bought. Agents maintain a catalog for matching with clients.

---

#### **💼 Deal (Сделка)**

A transaction connecting a **Client** and **Property**, representing the sales/buying process.

**Deal Lifecycle**:

```
LEAD
  ↓ (Initial contact/interest, no property assigned yet)
NEGOTIATION
  ↓ (Client interested in specific property, terms discussed)
CLOSED
  ↓ (Deal completed: CLOSED_WON or CLOSED_LOST)
```

**Deal Attributes**:

- Title (e.g., "Apartment sale on Kabanbay Ave")
- Status (LEAD → NEGOTIATION → CLOSED)
- Budget (client's budget/asking price)
- Deal price (final negotiated price)
- Notes (contract terms, conditions, etc.)
- Agent responsible
- Associated meetings and documents

**Deal Example**:

```
Client: Aidana (BUYER)
Property: 2-bed apartment in Astana
Status: NEGOTIATION
Budget: 50M KZT
Deal Price: 47.5M KZT
Agent: Aibek
Meetings: 3 scheduled
```

**Why it matters**: Deals track the entire transaction lifecycle. Agents can see at a glance:

- Which deals are active
- Which need urgently moved forward
- Which have closed (won or lost)

---

#### **📅 Meeting (Встреча)**

A scheduled interaction between an agent and a client, optionally linked to a deal.

**Meeting Attributes**:

- Title and description
- Scheduled date/time
- Location (office, property, remote)
- Completed status (boolean)
- Associated deal (optional)
- Agent and client

**Meeting Example**:

```
Title: "Viewing - Astana Tower Apt 405"
Scheduled: 2026-04-22 14:00
Location: Astana Tower, Kabanbay Ave
Deal: "Aidana apartment sale"
Agent: Aibek
Client: Aidana
Status: Pending (uncompleted)
```

---

### 3. **User Roles**

#### **👤 AGENT**

- Creates and manages clients
- Lists and manages properties
- Creates deals with clients
- Schedules meetings
- Tracks progress on deals
- Views only own clients and deals
- Cannot access admin functions

#### **👥 ADMIN**

- Full system access
- Can manage all agents
- Can view all deals and clients
- Can generate reports
- Can manage system settings

---

## 🔄 Daily Workflow

### **Agent's Typical Day**

**Morning - Dashboard Review**

```
Agent opens Dashboard
↓
Sees:
  - Total deals: 14
  - Active deals: 8
  - Closed deals: 6
↓
Reviews which deals need attention
```

**Mid-morning - Client Management**

```
Navigates to Clients page
↓
Sees: List of all clients with:
  - Name, phone, email
  - Deal status (LEAD/NEGOTIATION/CLOSED)
  - Budget and associated property
  - Next meeting date
  - Last contact date
↓
Can add new client via "Add Client" button
```

**Late Morning - Property Browsing**

```
Goes to Properties page
↓
Reviews available properties to match with clients
↓
Can filter by:
  - Status (AVAILABLE, RESERVED, SOLD)
  - Type (APARTMENT, HOUSE, etc.)
  - Price range
↓
Can add new property via "Add Property" button
```

**Afternoon - Deal Management**

```
Navigates to Deals page
↓
Sees all active deals with:
  - Title, client name, property
  - Current status (LEAD/NEGOTIATION/CLOSED)
  - Budget and deal price
↓
Updates deal status as negotiations progress:
  LEAD → NEGOTIATION → CLOSED (won/lost)
↓
Can add new deal via "Add Deal" button
```

**Late Afternoon - Meeting Scheduling**

```
Navigates to Meetings page
↓
Reviews all scheduled meetings
↓
Can filter: All / Pending / Completed
↓
Mark meetings as Complete when done
↓
Schedules new meetings with clients
```

**Before Leaving - Upcoming Check**

```
Navigates to "Upcoming" page
↓
Sees meetings grouped by date:
  - Today (3 meetings)
  - Tomorrow (2 meetings)
  - This week (5 meetings)
↓
Gets alerts if meetings are coming soon
```

---

## 📊 Key Business Metrics

The Dashboard displays:

```
┌─ TOTAL DEALS ─┐
│               │
│      14       │  All deals ever created
│               │
└───────────────┘

┌─ ACTIVE DEALS ─┐
│                │
│       8        │  LEAD + NEGOTIATION status
│                │
└────────────────┘

┌─ CLOSED DEALS ─┐
│                │
│       6        │  CLOSED_WON + CLOSED_LOST
│                │
└────────────────┘
```

**Agent's Performance Tracked**:

- Deal closure rate
- Average time per deal
- Number of active clients
- Meeting completion rate

---

## 💾 Data Model & Relationships

### **Entity Relationships**

```
USER (Agent/Admin)
  ├─ 1:N → CLIENT (owns)
  ├─ 1:N → DEAL (assigned to)
  ├─ 1:N → MEETING (scheduled with)
  └─ 1:N → PROPERTY (manages)

CLIENT
  ├─ 1:N → DEAL (has many deals)
  ├─ 1:N → MEETING (has many meetings)
  └─ M:1 → USER (belongs to agent)

PROPERTY
  ├─ 1:N → DEAL (can be in many deals)
  └─ M:1 → USER (managed by agent)

DEAL
  ├─ M:1 → CLIENT (belongs to)
  ├─ M:1 → PROPERTY (includes, optional until negotiation)
  ├─ M:1 → USER (assigned agent)
  ├─ 1:N → MEETING (related meetings)
  └─ 1:N → DOCUMENT (contract documents, etc.)

MEETING
  ├─ M:1 → CLIENT (with)
  ├─ M:1 → USER (scheduled by/with agent)
  ├─ M:1 → DEAL (optional reference)
  └─ Status (pending/completed)
```

### **Deal Status Lifecycle**

```
LEAD
  └─ Initial contact, interest expressed
     (Property may not be assigned yet)
     └─ Transition to NEGOTIATION when property identified

NEGOTIATION
  └─ Client and agent discussing terms
     Multiple meetings typically occur
     └─ Transition to CLOSED when agreement reached

CLOSED
  ├─ CLOSED_WON
  │   └─ Transaction completed successfully
  │       Documents signed
  │       Payment transferred
  │
  └─ CLOSED_LOST
      └─ Deal fell through
          Buyer/seller changed mind, or price/terms couldn't be agreed
```

---

## 🎮 Frontend Page & Feature Map

| Page           | Purpose                  | Actions                    | Data                                         |
| -------------- | ------------------------ | -------------------------- | -------------------------------------------- |
| **Dashboard**  | Overview & quick stats   | View metrics, nav to pages | Total/Active/Closed deals                    |
| **Clients**    | Client roster management | Add client, view list      | Name, type, budget, contact dates            |
| **Properties** | Property catalog         | Add property, view list    | Title, type, status, address                 |
| **Deals**      | Transaction tracking     | Add deal, change status    | Title, status, client, property, budget      |
| **Meetings**   | Meeting scheduler        | Add meeting, mark complete | Title, date/time, agent, client, deal        |
| **Upcoming**   | Week view of meetings    | View by date, edit         | Meetings grouped: Today, Tomorrow, This Week |

---

## 🔗 Common Workflows (Use Cases)

### **Use Case 1: New Client Acquisition**

```
1. Agent meets new BUYER interested in apartment
2. Agent goes to Clients page
3. Clicks "Add Client"
4. Fills: Name, Phone, Email, Type: BUYER, Budget: 50M KZT
5. Client saved ✓
6. Agent now can link this client to properties
```

### **Use Case 2: Create a Deal**

```
1. Agent has Client "Aidana" (BUYER) looking for 2-bed apartment
2. Agent finds Property "Astana Tower Apt 405" (AVAILABLE)
3. Agent goes to Deals page
4. Clicks "Add Deal"
5. Fills:
   - Title: "Aidana - Astana Tower Apartment"
   - Client: Select "Aidana"
   - Property: Select "Astana Tower Apt 405"
   - Status: LEAD
   - Budget: 50M KZT
6. Deal created ✓
7. Deal now visible on dashboard
```

### **Use Case 3: Schedule a Meet ing**

```
1. Agent want to meet Aidana for property viewing
2. Goes to Meetings page
3. Clicks "Add Meeting"
4. Fills:
   - Title: "Astana Tower Apt 405 - Viewing"
   - Client: Aidana
   - Deal: Aidana - Astana Tower Apartment
   - Agent: Self (current user)
   - Scheduled: 2026-04-22 14:00
   - Location: Astana Tower, Kabanbay Ave
5. Meeting saved ✓
6. Visible on Meetings & Upcoming pages
```

### **Use Case 4: Progress a Deal**

```
1. Deal status: LEAD (initial interest)
2. Agent meets client, shows property, discusses terms
3. Creates 2-3 meetings over few days
4. Deal looks promising → Client wants to proceed
5. Agent goes to Deals page
6. Clicks on deal row → Click status SELECT dropdown
7. Changes status: LEAD → NEGOTIATION
8. Deal now marked as active negotiation ✓
```

### **Use Case 5: Close a Deal**

```
1. Deal in NEGOTIATION status
2. Terms agreed, client ready to buy
3. Agent marks meetings as COMPLETED
4. Goes to Deals page
5. Changes deal status: NEGOTIATION → CLOSED (CLOSED_WON)
6. Deal removed from active count
7. Shows in "Closed Deals" on dashboard ✓
```

### **Use Case 6: Check This Week's Schedule**

```
1. Agent goes to "Upcoming" page
2. Sees meetings grouped:
   - Today (3): Viewing, Consultation, Sign contract
   - Tomorrow (2): Initial meet, Property viewing
   - Thursday (1): Final meeting
3. Can edit any meeting directly from cards
4. Can mark as completed with 1 click ✓
```

---

## 📱 Frontend Features & Business Rules

### **Automatic Data Calculations**

On **Clients List**, shows:

- `nextMeetingAt`: Next scheduled meeting with this client (calculated from meetings)
- `lastContactAt`: Most recent meeting or deal update
- `status`: Deal status with this client (from most recent deal)
- `budget`: Budget amount from most active deal
- `propertyTitle`: Current property of most active deal

### **Deal Status Rules**

- Deal starts as `LEAD`
- Can only move forward: LEAD → NEGOTIATION → CLOSED
- Cannot go backwards (no NEGOTIATION → LEAD)
- Once CLOSED, cannot reopen
- Agent must update meetings for date info

### **Meeting Logic**

- Meetings can be linked to Deals (optional)
- Meetings require Client + Agent always
- Must be scheduled in future (future validation)
- Can mark COMPLETED after scheduled time
- Completed meetings don't show on "Upcoming"

### **Property Status**

- AVAILABLE: Can be assigned to deals
- RESERVED: Linked to active deal
- SOLD: Deal closed, property unavailable
- Status updated manually (not auto-updated)

---

## 🎨 UI/UX Patterns Used

### **Drawers (Shadcn UI)**

Used for "Add" actions:

- Add Client → Drawer opens from right
- Add Property → Drawer
- Add Deal → Drawer
- Add Meeting → Dialog

### **Tables**

Standard paginated tables for viewing records:

- Clients Table: 8 columns (name, phone, email, status, budget, property, meetings, last contact)
- Properties Table: 5 columns (title, location, type, status, price)
- Deals Table: 5 columns (title, client, property, status, budget)
- Meetings Table: 4 columns (title, date, agent, client)

### **Status Indicators**

- Deal status: Dropdown SELECT to change inline
- Property status: Colored badges (green=available, yellow=reserved, gray=sold)
- Meeting status: Checkbox or "Mark done" button for completion

### **Date Formatting**

- UI uses: "Apr 22, 2026, 2:30 PM" format
- Relative dates when possible: "Today", "Tomorrow"
- Time differences: "In 2 hours", "Yesterday"

---

## 🔐 Permission Model

### **Agent Can**

- ✅ View own clients
- ✅ Create/edit own deals
- ✅ Create/schedule meetings
- ✅ View own properties
- ✅ Mark meetings complete
- ❌ Cannot access other agent's data
- ❌ Cannot access admin functions

### **Admin Can**

- ✅ View all clients, deals, properties, meetings
- ✅ Create/edit any data
- ✅ Manage other agents
- ✅ Generate reports
- ✅ System administration

---

## 💡 Key Business Insights

1. **Deal-Centric Design**: Everything revolves around deals. Each deal is a transaction lifecycle.

2. **Meeting-Heavy**: Real estate requires many meetings (viewings, consultations, signings). The "Upcoming" page helps agents stay organized.

3. **Client Relationship Focus**: Clients table shows next meeting and last contact - helps agents prioritize follow-ups.

4. **Status Transparency**: Deal status is the main progress indicator. Can see at a glance which deals are leads vs. active vs. closed.

5. **Agent Accountability**: Each deal, client, and meeting is assigned to an agent. Enables performance tracking.

6. **Portfolio Diversification**: Properties catalog decoupled from deals - agents can manage inventory and match flexibly.

---

## 📈 Future Enhancement Ideas

- 💬 Messaging/notes between agent and client
- 📊 Advanced analytics (conversion rates, ROI per agent)
- 🤝 Team collaboration (multiple agents on one deal)
- 📄 Document management (contracts, offers, inspections)
- 🔔 Notifications for upcoming meetings
- 📞 Call/SMS logging with clients
- 🗓️ Calendar integration (Google, Outlook)
- 💰 Payment tracking and commission calculations
- 📸 Photo gallery for properties
- 🌍 Map view for properties

---

## 🎯 Summary

**Estate CRM** streamlines the complex real estate sales process for agents by:

1. **Organizing people** (Clients) with their needs and budgets
2. **Managing assets** (Properties) available for sale
3. **Tracking transactions** (Deals) from initial interest to closure
4. **Scheduling interactions** (Meetings) to move deals forward
5. **Providing visibility** (Dashboard) into performance metrics
6. **Enabling accountability** by assigning responsibility to agents

The frontend provides all necessary tools for agents to manage their pipelines effectively and close more deals.

---

## 📚 Data Flow Summary

```
Login
  ↓
Dashboard (see stats)
  ↓
Clients (find client or add new)
  ↓
Properties (find matching property)
  ↓
Deals (create transaction linking client + property)
  ↓
Meetings (schedule viewings/consultations)
  ↓
Status Updates (move deal from LEAD → NEGOTIATION → CLOSED)
  ↓
Analysis (review upcoming, closed deals on dashboard)
```

This creates a complete CRM workflow for managing real estate transactions.
