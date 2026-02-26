# EcoTrade Rwanda Platform

## Project Description

EcoTrade Rwanda is a digital B2B marketplace connecting waste generators (hotels, restaurants, businesses) with recyclers, drivers, and individual collectors in Kigali, Rwanda. The platform enables transparent waste-to-resource transactions while promoting environmental sustainability and creating economic opportunities.

## Key Features

- **Multi-Role Dashboard System** — Admin, Business, Recycler, Driver, Individual
- **Waste Marketplace** — Listings for recyclable materials (UCO, glass, paper, plastic)
- **Green Score Certification** — Environmental performance scoring and certificates
- **Impact Analytics** — CO₂ savings, waste diverted, water saved
- **Logistics Management** — Route planning and collection scheduling
- **Financial Tracking** — Transaction history, revenue reports, earnings statements
- **PDF Report Exports** — All reports download as formatted PDFs with full data
- **OTP Two-Factor Authentication** — Secure login with SMS/email OTP
- **Role-based Settings** — Editable profiles with notification preferences

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18+ with TypeScript |
| Build Tool | Vite |
| Styling | TailwindCSS |
| Routing | React Router v6 |
| Icons | Lucide React |
| State | React Context API + localStorage |
| Animations | Framer Motion |
| Charts | Chart.js via ChartComponent |

## Demo Login Credentials

| Role | Email | Password | Dashboard |
|------|-------|----------|-----------|
| Admin | admin@ecotrade.rw | admin123 | /dashboard/admin |
| Business | business@ecotrade.rw | business123 | /dashboard/business |
| Recycler | recycler@ecotrade.rw | recycler123 | /dashboard/recycler |
| Driver | driver@ecotrade.rw | driver123 | /dashboard/driver |
| Individual | individual@ecotrade.rw | user123 | /dashboard/individual |

> OTP code (2FA): **123456**

## Links

- **GitHub:** https://github.com/Daniel-IRYIVUZE/kcem_platform.git
- **Live Demo:** https://ecotrade-rwanda.netlify.app
- **Demo Video:** *(link pending)*

## Setup Instructions

### Prerequisites

- Node.js v18.0.0 or higher
- npm v9.0.0 or higher
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/Daniel-IRYIVUZE/kcem_platform.git
cd kcem_platform/web-frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

## Project Structure

```
kcem_platform/
├── LICENSE
├── README.md
└── web-frontend/
    ├── public/
    │   ├── manifest.json
    │   └── robots.txt
    └── src/
        ├── assets/
        │   ├── images/
        │   └── styles/
        ├── components/
        │   ├── about/
        │   ├── auth/
        │   ├── blog/
        │   ├── common/
        │   ├── contact/
        │   ├── dashboard/
        │   │   ├── admin/
        │   │   ├── business/
        │   │   ├── driver/
        │   │   ├── individual/
        │   │   └── recycler/
        │   ├── home/
        │   ├── marketplace/
        │   └── services/
        ├── context/
        │   └── AuthContext.tsx
        ├── pages/
        │   ├── About/
        │   ├── Blog/
        │   ├── Contact/
        │   ├── Dashboard/
        │   ├── Home/
        │   ├── Login/
        │   ├── Marketplace/
        │   ├── NotFound/
        │   ├── Services/
        │   └── TermsPrivacy/
        ├── utils/
        │   └── dataStore.ts
        ├── App.tsx
        └── main.tsx
```

## Deployment

### Netlify

```bash
npm install -g netlify-cli
netlify login
cd web-frontend
npm run build
netlify deploy --prod
```

Live URL: https://ecotrade-rwanda.netlify.app

## License

MIT License — see [LICENSE](./LICENSE) file for details.

## Contact

- Email: contact@ecotrade.rw
- Phone: +250 780 162 164
- Website: https://ecotrade-rwanda.netlify.app

