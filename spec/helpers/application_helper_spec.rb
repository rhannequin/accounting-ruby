# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper do
  describe "alert_class" do
    it "returns :success when providing :notice" do
      expect(helper.alert_class(:notice)).to eq(:success)
    end

    it "returns :success when providing :success" do
      expect(helper.alert_class(:success)).to eq(:success)
    end

    it "returns :warning when providing :warning" do
      expect(helper.alert_class(:warning)).to eq(:warning)
    end

    it "returns :info when providing :info" do
      expect(helper.alert_class(:info)).to eq(:info)
    end

    it "returns :danger when providing something else" do
      expect(helper.alert_class(:something_else)).to eq(:danger)
    end
  end

  describe "empty_char" do
    it "returns a String" do
      expect(helper.empty_char).to be_kind_of(String)
    end
  end

  describe "provider_profile_link" do
    it "returns Twitter link account when providing provider: 'twitter'" do
      expect(helper.provider_profile_link("twitter", 1)).to be_kind_of(String)
      expect(helper.provider_profile_link("twitter", 1)).to match(/twitter/)
    end

    it "returns Twitter link account when providing provider: 'facebook'" do
      expect(helper.provider_profile_link("facebook", 1)).to be_kind_of(String)
      expect(helper.provider_profile_link("facebook", 1)).to match(/facebook/)
    end

    it "returns empty characeter when not providing provider" do
      expect(helper.provider_profile_link(nil, nil)).to be_kind_of(String)
      expect(helper.provider_profile_link(nil, nil)).to eq(helper.empty_char)
    end
  end

  describe "empty_char" do
    it "returns list of role names" do
      roles = [Role.new(name: :admin), Role.new(name: :other)]
      expect(helper.roles_list(roles)).to eq("admin, other")
    end

    it "returns empty character when providing empty array" do
      expect(helper.roles_list([])).to eq(helper.empty_char)
    end
  end
end
