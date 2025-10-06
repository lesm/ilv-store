# ILV Store

An e-commerce platform for selling books and managing orders with integrated payment processing.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Project Structure](#project-structure)

## Features

### Customer Features
- **Product Catalog**: Browse and search books with detailed information
- **Shopping Cart**: Add, update, and remove items from cart
- **User Authentication**: Secure registration and login with email verification
- **Order Management**: Create and track orders
- **Address Management**: Save and manage shipping addresses with postal code validation
- **Multi-language Support**: Internationalization (i18n) ready
- **Payment Integration**: Stripe payment processing

### Admin Features (Backoffice)
- **Dashboard**: Overview of store statistics
- **Product Management**: CRUD operations for books and products
- **Order Management**: View and manage customer orders
- **Label Price Management**: Configure pricing for product labels by weight ranges
- **File Uploads**: Product cover images with Active Storage

## Tech Stack

- **Framework**: Ruby on Rails 8.0.2
- **Ruby Version**: 3.4.4
- **Database**: PostgreSQL with multiple databases:
  - Primary (application data)
  - Cache (Solid Cache)
  - Queue (Solid Queue for background jobs)
  - Cable (Solid Cable for WebSockets)
- **Frontend**:
  - Hotwire (Turbo & Stimulus)
  - TailwindCSS
  - Importmap for JavaScript
- **Background Jobs**: Solid Queue with Mission Control
- **Payment Processing**: Stripe
- **File Storage**: Active Storage (AWS S3 compatible)
- **Error Tracking**: Sentry
- **Testing**: Minitest with FactoryBot, Capybara, and Selenium
- **Code Quality**: RuboCop, Brakeman, SimpleCov

## Requirements

- Ruby 3.4.4
- PostgreSQL (version 9.3+)
- Node.js (for asset compilation)
- Redis (optional, for caching)
- Libvips (for image processing)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ilv-store
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up environment variables**

   Create a `.env` file in the project root with the following variables:
   ```env
   cp .env.example .env
   ```

4. **Create and setup databases**
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

## Configuration

### Database Setup

The application uses PostgreSQL with four separate databases:
- `ilv_store_development` - Primary application database
- `ilv_store_development_cache` - Cache storage
- `ilv_store_development_queue` - Background job queue
- `ilv_store_development_cable` - WebSocket connections

All databases are automatically created with `db:create`.

### Stripe Webhooks

For local development, use Stripe CLI to forward webhooks:
```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

## Development

### Running the Application

Start the development server with Foreman (runs Rails server and TailwindCSS watcher):
```bash
bin/dev
```

Or run services individually:
```bash
# Rails server
bin/rails server

# TailwindCSS watcher
bin/rails tailwindcss:watch

# Background job processor
bin/jobs start
```

The application will be available at `http://localhost:3000`

### Background Jobs

Monitor background jobs with Mission Control:
```
http://localhost:3000/jobs
```

### Admin Access

Access the backoffice at `/backoffice/dashboard` (requires admin authentication).

## Testing

### Run the full test suite
```bash
bin/rails test:all
```

### Run unit tests
```bash
bin/rails test
```

### Run system tests
```bash
bin/rails test:system
```

### Code Quality Tools

```bash
# RuboCop (linting)
bundle exec rubocop

# Brakeman (security scanning)
bundle exec brakeman

# Database consistency checks
bundle exec database_consistency

# ERB linting
bundle exec erblint --lint-all
```

## Deployment

The application is configured for deployment with Kamal:

```bash
# Setup
kamal setup

# Deploy
kamal deploy

# Other commands
kamal app logs
kamal app exec 'bin/rails console'
```
