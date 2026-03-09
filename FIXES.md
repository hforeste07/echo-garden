# Echo Garden — Prioritized Improvement Plan

## P0 — Critical (Security / Broken Architecture / Must Fix Before Shipping)

---

### P0-1: IDOR Vulnerability — GardenPlotsController does not scope to current_user

**File**: `app/controllers/garden_plots_controller.rb`
**Problem**: `GardenPlot.find(params[:id])` is called without verifying that the current user owns the plot. Any authenticated user can read or modify any garden plot by guessing an ID.

```ruby
# CURRENT (VULNERABLE)
def update
  @garden_plot = GardenPlot.find(params[:id])  # No ownership check
  @plant = Plant.find(params[:plant_id])
  ...
end

def show
  @plot = GardenPlot.find(params[:id])  # No ownership check
end

def edit
  @garden_plot = GardenPlot.find(params[:id])  # No ownership check
end

def plant
  @plot = GardenPlot.find(params[:id])  # No ownership check
end
```

**Suggested fix**: Scope all garden plot lookups through the current user's gardens.

```ruby
# FIXED
before_action :set_garden_plot, only: [:show, :edit, :update, :plant]

private

def set_garden_plot
  @garden_plot = current_user.gardens
                              .joins(:garden_plots)
                              .map(&:garden_plots)
                              .flatten
                              .find { |gp| gp.id == params[:id].to_i }
  redirect_to dashboard_path, alert: "Not authorized." unless @garden_plot
end
```

Or more efficiently, add a helper scope to the model:

```ruby
# app/models/garden_plot.rb
def self.for_user(user)
  joins(:garden).where(gardens: { user_id: user.id })
end

# app/controllers/garden_plots_controller.rb
def set_garden_plot
  @garden_plot = GardenPlot.for_user(current_user).find(params[:id])
rescue ActiveRecord::RecordNotFound
  redirect_to dashboard_path, alert: "Not authorized."
end
```

---

### P0-2: No Authorization Framework

**File**: All controllers
**Problem**: The app has authentication (Devise) but no authorization. Any authenticated user can potentially access resources belonging to other users. There is no concept of "can this user do this action on this resource?"

**Suggested fix**: Add Pundit.

```ruby
# Gemfile
gem "pundit"

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
end

# app/policies/garden_plot_policy.rb
class GardenPlotPolicy < ApplicationPolicy
  def show?
    record.garden.user == user
  end

  def update?
    record.garden.user == user
  end

  alias_method :edit?, :update?
  alias_method :plant?, :update?
end
```

---

### P0-3: Strong Params Are Broken

**File**: `app/controllers/gardens_controller.rb`, `app/controllers/garden_plots_controller.rb`
**Problem**: `garden_params` permits only `:id` which is not a meaningful parameter to permit. The `update` action calls `garden_params.merge(plant_id: plant_id)` adding `plant_id` outside of the permitted params pattern. `GardenPlotsController` takes `params[:plant_id]` directly with no strong params at all.

```ruby
# CURRENT (BROKEN)
def garden_params
  params.require(:garden).permit(:id)  # :id should never be mass-assigned
end

# In GardenPlotsController#update (no strong params)
@plant = Plant.find(params[:plant_id])  # Direct param access
```

**Suggested fix**:

```ruby
# app/controllers/garden_plots_controller.rb
def garden_plot_params
  params.permit(:plant_id)
end

def update
  @garden_plot = GardenPlot.for_user(current_user).find(params[:id])
  if @garden_plot.update(garden_plot_params)
    redirect_to @garden_plot.garden, notice: "Plot updated."
  else
    redirect_to @garden_plot, alert: @garden_plot.errors.full_messages.join(", ")
  end
end
```

---

### P0-4: CI/CD Is Completely Disabled

**File**: `.github/workflows/ci.yml`
**Problem**: All meaningful CI jobs are commented out. The only active job echoes "CI jobs disabled." This means no tests, no linting, and no security scans run on any pull request.

```yaml
# CURRENT (non-functional)
jobs:
  placeholder:
    runs-on: ubuntu-latest
    steps:
      - run: 'echo "CI jobs disabled"'
```

**Suggested fix**: Enable at minimum a test runner and linter. Uncomment the existing scan jobs and add a test step.

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true
      - name: Set up database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost/test
        run: bin/rails db:create db:schema:load
      - name: Run tests
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost/test
        run: bundle exec rspec

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true
      - run: bundle exec rubocop --parallel
```

---

### P0-5: Zero Meaningful Tests

**File**: `spec/features/sample_spec.rb` (and all missing spec files)
**Problem**: The only test is `expect(1).to eq(1)`. No authentication flows, no model validations, no controller behaviors, and no feature specs are tested. The full testing infrastructure (RSpec, Capybara, Shoulda Matchers, WebMock) is installed but unused.

**Suggested fix**: At a minimum, write model and feature specs for core flows:

```ruby
# spec/models/garden_spec.rb
require "rails_helper"

RSpec.describe Garden, type: :model do
  describe "after_create callbacks" do
    it "generates the correct number of plots" do
      user = create(:user)
      garden = create(:garden, user: user, rows: 3, columns: 4)
      expect(garden.garden_plots.count).to eq(12)
    end

    it "marks the first garden as favorite" do
      user = create(:user)
      garden = create(:garden, user: user)
      expect(garden.favorite).to be true
    end
  end
end

# spec/features/garden_plots_spec.rb
require "rails_helper"

RSpec.describe "Garden plot authorization", type: :feature do
  it "prevents users from editing other users' plots" do
    owner = create(:user)
    attacker = create(:user)
    garden = create(:garden, user: owner)
    plot = garden.garden_plots.first

    sign_in attacker
    visit edit_garden_plot_path(plot)
    expect(page).to have_current_path(dashboard_path)
  end
end
```

---

## P1 — Important (Maintainability / Convention / Must Fix Before Review)

---

### P1-1: Application Module Name Not Updated from Template

**File**: `config/application.rb`
**Problem**: The application module is still named `Rails8Template`, which is the default generated by the Rails 8 template this project was scaffolded from.

```ruby
# CURRENT
module Rails8Template
  class Application < Rails::Application
```

**Suggested fix**:

```ruby
module EchoGarden
  class Application < Rails::Application
```

---

### P1-2: Duplicate and Non-RESTful Routes

**File**: `config/routes.rb`
**Problem**: Multiple routing issues:
1. `get "gardens/index"` and `get "gardens/show"` declared redundantly alongside `resources :gardens`
2. `resources :garden_plots` declared twice (nested and top-level)
3. `GardenPlotsController#plant` is a non-RESTful custom action duplicating `update`
4. `plants#autocomplete` route declared but no action exists

```ruby
# CURRENT (messy)
get "gardens/index"
get "gardens/show"
resources :gardens do
  resources :garden_plots, only: [:create, :update, :destroy]
end
resources :garden_plots, only: [:update, :edit, :show] do
  member do
    patch :plant
  end
end
resources :plants, only: [:index] do
  collection do
    get :autocomplete  # No action exists
    get :search        # No action exists
  end
end
```

**Suggested fix**:

```ruby
# CLEANED UP
Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  root to: "home#index"

  resource :dashboard, only: [:show]

  resources :gardens, only: [:index, :show, :update] do
    resources :garden_plots, only: [:show, :edit, :update]
  end

  resources :plants, only: [:index]

  resources :locations, only: [:index] do
    get :cities, on: :collection
  end
end
```

---

### P1-3: Repeated `Plant.all` Queries Across Controllers (DRY Violation)

**Files**: `app/controllers/plants_controller.rb`, `app/controllers/garden_plots_controller.rb`
**Problem**: `Plant.all` is called in three separate controller actions with no scoping. This:
- Creates N+1 risk when associated data is loaded later
- Violates DRY — the query is not centralized
- Will become a performance issue as the plant database grows

```ruby
# plants_controller.rb
@plants = Plant.all

# garden_plots_controller.rb (edit action)
@available_plants = Plant.all

# garden_plots_controller.rb (show action)
@plants = Plant.all
```

**Suggested fix**: Add a scope to the model and consolidate:

```ruby
# app/models/plant.rb
scope :by_common_name, -> { order(:common_name) }
scope :for_region, ->(location) { joins(:native_regions).where(locations: { id: location.id }) }
```

---

### P1-4: Flash Messages Are Unstyled

**File**: `app/views/shared/_flash_messages.html.erb`
**Problem**: Flash messages render as plain `<p>` tags with no Bootstrap alert classes. Users see plain text with no visual distinction between success and error states.

```erb
<%# CURRENT — plain paragraph tags %>
<p><%= notice %></p>
<p><%= alert %></p>
```

**Suggested fix**:

```erb
<% flash.each do |type, message| %>
  <% css_class = type.to_s == "alert" ? "alert-danger" : "alert-success" %>
  <div class="alert <%= css_class %> alert-dismissible fade show" role="alert">
    <%= message %>
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
<% end %>
```

---

### P1-5: Inline CSS in Garden Grid Partial

**File**: `app/views/gardens/_grid.html.erb`
**Problem**: Grid layout, cell dimensions, and colors are hardcoded as inline styles. This makes the grid impossible to restyle via CSS and violates separation of concerns.

```erb
<%# CURRENT — inline styles in ERB %>
<div style="display: grid; grid-template-columns: repeat(<%= garden.columns %>, 40px); gap: 4px;">
  <div style="width: 40px; height: 40px; background-color: <%= plot.plant ? 'green' : 'tan' %>;">
```

**Suggested fix**: Extract to CSS with data attributes for dynamic values:

```css
/* app/assets/stylesheets/application.css */
.garden-grid {
  display: grid;
  gap: 4px;
}

.garden-cell {
  width: 40px;
  height: 40px;
}

.garden-cell--planted {
  background-color: #2d6a4f;
}

.garden-cell--empty {
  background-color: #d4a373;
}
```

```erb
<%# Updated partial %>
<div class="garden-grid"
     style="grid-template-columns: repeat(<%= garden.columns %>, 40px);">
  <% garden.garden_plots.each do |plot| %>
    <div class="garden-cell <%= plot.plant ? 'garden-cell--planted' : 'garden-cell--empty' %>">
```

Note: The `grid-template-columns` value must remain dynamic since it depends on `garden.columns`.

---

### P1-6: Mailer Default From Address Not Configured

**File**: `app/mailers/application_mailer.rb`, `config/environments/production.rb`
**Problem**: Mailer is configured with `from@example.com` and production host is `example.com`. If Devise sends any password reset or confirmation emails, they will be broken.

```ruby
# app/mailers/application_mailer.rb
default from: "from@example.com"  # Placeholder

# config/environments/production.rb
config.action_mailer.default_url_options = { host: "example.com" }  # Placeholder
```

**Suggested fix**: Update with actual values or use environment variables:

```ruby
# app/mailers/application_mailer.rb
default from: ENV.fetch("MAILER_FROM", "noreply@echo-garden.com")

# config/environments/production.rb
config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "echo-garden.onrender.com") }
```

---

### P1-7: Missing .env.example File

**Files**: Root directory (missing), `app/services/plants_importer.rb`, `app/services/locations_importer.rb`
**Problem**: Two API keys are required (`TREFLE_API_KEY`, `COUNTRY_STATE_CITY_API_KEY`) but are completely undocumented. A new developer has no way to know what environment variables to set.

**Suggested fix**: Create `.env.example` in the project root:

```bash
# .env.example
# Copy to .env and fill in your values
# Never commit .env to git!

# Required for plant data import (Trefle API)
# Get your key at: https://trefle.io/users/sign_in
TREFLE_API_KEY=your_trefle_api_key_here

# Required for location data import (Country State City API)
# Get your key at: https://countrystatecity.in/
COUNTRY_STATE_CITY_API_KEY=your_api_key_here

# Required for error monitoring (Rollbar)
ROLLBAR_ACCESS_TOKEN=your_rollbar_token_here

# Production only
APP_HOST=your-app.onrender.com
MAILER_FROM=noreply@your-domain.com
```

Also verify `.env` is in `.gitignore`.

---

### P1-8: GardenPlotsController Has Duplicate `update` and `plant` Actions

**File**: `app/controllers/garden_plots_controller.rb`
**Problem**: Both `update` and `plant` actions do the same thing (assign a plant to a plot). Having two methods for one operation violates DRY and creates confusion.

```ruby
def update
  @garden_plot = GardenPlot.find(params[:id])
  @plant = Plant.find(params[:plant_id])
  if @garden_plot.update(plant: @plant)  ...

def plant
  @plot = GardenPlot.find(params[:id])
  @plot.update(plant_id: params[:plant_id])  ...
```

**Suggested fix**: Remove `plant` action entirely and use only `update` with proper strong params.

---

### P1-9: `GardensController#update` Incorrectly Handles Garden Plots

**File**: `app/controllers/gardens_controller.rb`
**Problem**: The `update` action on a Garden calls `@garden.update(garden_params.merge(plant_id: plant_id))` — but `plant_id` is not a column on the `gardens` table. This will silently fail or raise an error.

```ruby
def update
  @garden = current_user.gardens.find(params[:id])
  plant_id = params[:garden_plot][:plant_id]

  if @garden.update(garden_params.merge(plant_id: plant_id))
    # plant_id is not on the gardens table!
```

**Suggested fix**: Remove this action or redirect to the correct controller. Garden plot plant assignment should go through `GardenPlotsController#update`.

---

## P2 — Polish (UX / Documentation / Enhancements)

---

### P2-1: README Needs Setup Instructions

**File**: `README.md`
**Problem**: New developers cannot set up the project locally from the README.

**Suggested addition**:

```markdown
## Setup

### Prerequisites
- Ruby 3.4.1
- PostgreSQL
- Node.js

### Installation

1. Clone the repository: `git clone https://github.com/your-org/echo-garden.git && cd echo-garden`
2. Install dependencies: `bundle install`
3. Copy environment variables: `cp .env.example .env` and fill in your API keys
4. Create and seed the database: `bin/rails db:create db:migrate`
5. Import locations: `bin/rake locations:import`
6. Import plants: `bin/rake plants:import`
7. Start the server: `bin/dev`
8. Visit `http://localhost:3000`
```

---

### P2-2: Add Scopes to Plant Model

**File**: `app/models/plant.rb`
**Problem**: No scopes defined. As the plant database grows (potentially thousands of records), `Plant.all` will become slow.

**Suggested addition**:

```ruby
# app/models/plant.rb
scope :by_common_name, -> { order(:common_name) }
scope :native_to, ->(location) { joins(:native_regions).where(locations: { id: location.id }) }
scope :with_light, ->(light) { where(light_requirements: light) }
```

---

### P2-3: Add Semantic HTML to Views

**Files**: View templates
**Problem**: Core page structure does not use `<main>`, `<article>`, or `<section>` tags, reducing accessibility and SEO value.

**Suggested fix**: Wrap page content in `<main>` in `application.html.erb`:

```erb
<body>
  <%= render "shared/navbar" %>
  <main role="main" class="container mt-4">
    <%= render "shared/flash_messages" %>
    <%= yield %>
  </main>
  <footer>...</footer>
</body>
```

---

### P2-4: Add Alt Tags to Plant Images

**Files**: View templates that render `plant.image_url`
**Problem**: Plant images likely render without `alt` attributes, failing accessibility standards.

**Suggested fix**:

```erb
<%= image_tag plant.image_url, alt: plant.common_name, class: "plant-image" if plant.image_url? %>
```

---

### P2-5: Conflicting and Duplicate Rake Tasks

**Files**: `lib/tasks/import_plants.rake`, `lib/tasks/plants_import.rake`, `lib/tasks/sample_data.rake`
**Problem**: Two rake tasks both appear to import plants under different names. `sample_data.rake` is empty.

**Suggested fix**:
- Delete `plants_import.rake` (keep only `import_plants.rake`)
- Delete `sample_data.rake` or implement it with Faker-based seed data
- Consolidate to a single canonical `rake plants:import` task

---

### P2-6: `config/schedule.rb` Has Inconsistent Scheduling

**File**: `config/schedule.rb`
**Problem**: Imports are scheduled both yearly (too infrequent for a live app) and every 6 minutes (too frequent for a batch import job that hits rate-limited external APIs).

```ruby
every 1.year, at: '2:00 am' do
  runner "LocationsImportJob.perform_later"
end

every 6.minutes do
  rake "flora:import"
end
```

**Suggested fix**: Align scheduling with actual requirements. Locations change rarely (monthly or quarterly). Plants should import once with manual re-runs as needed.

---

### P2-7: Implement Ransack and Pagination That Are Already Installed

**Files**: `app/controllers/plants_controller.rb`
**Problem**: Both Ransack and Kaminari/Pagy are in the Gemfile but unused. The plants list will become unusably long without search and pagination.

**Suggested implementation**:

```ruby
# app/controllers/plants_controller.rb
def index
  @q = Plant.ransack(params[:q])
  @pagy, @plants = pagy(@q.result(distinct: true).by_common_name, items: 24)
end
```

```erb
<%# app/views/plants/index.html.erb %>
<%= search_form_for @q do |f| %>
  <%= f.label :common_name_cont, "Search by name" %>
  <%= f.search_field :common_name_cont, class: "form-control" %>
  <%= f.submit "Search", class: "btn btn-primary" %>
<% end %>

<% @plants.each do |plant| %>
  <%# plant card %>
<% end %>

<%== pagy_bootstrap_nav(@pagy) %>
```

---

### P2-8: Add Contribution Guidelines to README

**File**: `README.md`
**Problem**: No contribution instructions mean new contributors don't know the expected workflow.

**Suggested addition**:

```markdown
## Contributing

1. Branch from `main` using the format: `initials-feature-description` (e.g., `jd-add-plant-search`)
2. Make your changes with clear, descriptive commit messages
3. Open a pull request against `main` with a description of what changed and why
4. Request a review before merging
5. Do not push directly to `main`
```

---

## Summary Table

| Priority | Count | Highest Impact Items |
|----------|-------|---------------------|
| P0 | 5 | IDOR vulnerability, no auth framework, broken strong params, disabled CI, no tests |
| P1 | 9 | Module name, route cleanup, DRY queries, flash styling, inline CSS, env docs |
| P2 | 8 | README setup steps, semantic HTML, alt tags, rake cleanup, search/pagination |

**Recommended sprint order**: P0-4 (CI) → P0-5 (tests) → P0-1/P0-2/P0-3 (security) → P1-1 through P1-4
