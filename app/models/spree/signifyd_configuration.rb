module Spree
  class SignifydConfiguration < Preferences::Configuration
    preference :api_key, :string
    preference :exclude_store_credit_orders, :boolean, default: false
    preference :signifyd_score_threshold, :integer, default: 500 # Signifyd's recommended threshold
    preference :signifyd_dashboard_case_url, :string, default: 'https://app.signifyd.com/cases/:case_id'
  end
end
