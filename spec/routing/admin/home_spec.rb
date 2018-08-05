# frozen_string_literal: true

require "rails_helper"

describe "routing to admin homepage" do
  it "routes GET /admin to admin_home#index" do
    expect(get: "/admin").to route_to(
      controller: "admin/home",
      action: "index"
    )
  end
end
