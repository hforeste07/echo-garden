import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["country", "state", "city", "locationId"]

  connect() {
    fetch("/locations.json")
      .then(res => res.json())
      .then(data => {
        this.countries = data.countries
        this.statesByCountry = data.states

        // Populate country dropdown
        this.countryTarget.innerHTML = "<option>Select Country</option>" +
          this.countries.map(c => `<option value="${c}">${c}</option>`).join("")

        // Preselect values if editing user
        const selectedCountry = this.countryTarget.dataset.selected
        const selectedState = this.stateTarget.dataset.selected
        const selectedCityId = this.cityTarget.dataset.selected

        if (selectedCountry) {
          this.countryTarget.value = selectedCountry
          this.populateStates(selectedCountry, selectedState)
          if (selectedState) {
            this.populateCities(selectedCountry, selectedState, selectedCityId)
          }
        }
      })
      .catch(e => console.error(e))
  }

  countryChanged() {
    const country = this.countryTarget.value
    this.populateStates(country)
    this.cityTarget.innerHTML = "<option>Select a state first</option>"
    this.locationIdTarget.value = ""
  }

  stateChanged() {
    const country = this.countryTarget.value
    const state = this.stateTarget.value
    this.populateCities(country, state)
  }

  populateStates(country, selectedState = null) {
    const states = this.statesByCountry[country] || []
    this.stateTarget.innerHTML = "<option>Select State</option>" +
      states.map(s => `<option value="${s.province}" ${s.province === selectedState ? "selected" : ""}>${s.province}</option>`).join("")
  }

  populateCities(country, state, selectedCityId = null) {
    fetch(`/locations/cities?country=${encodeURIComponent(country)}&state=${encodeURIComponent(state)}`)
      .then(res => res.json())
      .then(cities => {
        this.cityTarget.innerHTML = "<option>Select City</option>" +
          cities.map(c => `<option value="${c.id}" ${c.id == selectedCityId ? "selected" : ""}>${c.city}</option>`).join("")
      })
      .catch(e => console.error(e))
  }

  cityChanged() {
    this.locationIdTarget.value = this.cityTarget.value
  }
}
