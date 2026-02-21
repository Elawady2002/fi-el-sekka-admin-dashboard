# Fi El Sekka Admin Dashboard (Next.js Version)

Professional admin dashboard for Fi El Sekka transportation application built with Next.js, Tailwind CSS, and Supabase.

## Features

- ✅ Modern Dashboard Overview
- ✅ Swiss Clean Design System
- ✅ Responsive Layout
- ✅ Lucide React Icons
- ✅ Supabase Integration (Auth & Database)
- ✅ Zero Radius Geometric Aesthetic

## Tech Stack

- **Framework**: Next.js 14/15 (App Router)
- **Styling**: Tailwind CSS 4
- **Backend**: Supabase
- **Icons**: Lucide React
- **Animations**: Framer Motion
- **Fonts**: Space Grotesk (Display), Inter (Body)

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env.local` file (already created with your credentials):
```bash
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

3. Run the development server:
```bash
npm run dev
```

## Project Structure

```
src/
├── app/             # Next.js App Router pages
├── components/      # UI Components
│   └── layout/      # Sidebar and Layout components
├── lib/             # Utilities and Supabase client
│   ├── supabase.ts
│   └── utils.ts
└── globals.css      # Design system and tailwind styles
```

## Original Flutter Project
The original Flutter Web project has been moved to `flutter_backup/` for reference.

## License
Private project - All rights reserved
