# frozen_string_literal: true

require "rails_helper"

describe "routing to users" do
  it "routes GET /admin/users to admin_users#index" do
    expect(get: "/admin/users").to route_to(
      controller: "admin/users",
      action: "index"
    )
  end

  it "routes GET /admin/users/1 to admin_users#show" do
    expect(get: "/admin/users/1").to route_to(
      controller: "admin/users",
      action: "show",
      id: "1"
    )
  end

  it "routes DELETE /admin/users/1 to admin_users#destroy" do
    expect(delete: "/admin/users/1").to route_to(
      controller: "admin/users",
      action: "destroy",
      id: "1"
    )
  end
end
