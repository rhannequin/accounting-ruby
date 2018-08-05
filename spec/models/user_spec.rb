# frozen_string_literal: true

require "rails_helper"

describe User, type: :model do
  let(:user) { create :user }

  describe "email" do
    it "must be unique" do
      email = "unique@email.com"
      create :user, email: email
      expect(build(:user, email: email)).not_to be_valid
    end
  end

  describe "passwords" do
    it "has a password attribute" do
      expect(user).to respond_to(:password)
    end

    it "has a password confirmation attribute" do
      expect(user).to respond_to(:password_confirmation)
    end
  end

  describe "password validations" do
    it "requires a password" do
      expect(build(:user, password: "", password_confirmation: ""))
        .not_to be_valid
    end

    it "requires a matching password confirmation" do
      expect(build(:user, password_confirmation: "invalid")).not_to be_valid
    end

    it "rejects short passwords" do
      short = "a" * 5
      expect(build(:user, password: short, password_confirmation: short))
        .not_to be_valid
    end
  end

  describe "password encryption" do
    it "has an encrypted password attribute" do
      expect(user).to respond_to(:encrypted_password)
    end

    it "sets the encrypted password attribute" do
      expect(user.encrypted_password).not_to be_blank
    end
  end

  describe "name" do
    it "must be unique" do
      name = "Jane"
      create :user, name: name
      expect(build(:user, name: name)).not_to be_valid
    end
  end

  describe "slug" do
    let(:user) { create :user }

    it "changes when name is changed" do
      slug = user.slug
      user.name = "Jane"
      user.save
      expect(user.slug).not_to eq(slug)
    end

    it "stays the same if the name does not change" do
      Setting.create email: "test@example.com"
      slug = user.slug
      user.email = "example@test.com"
      user.save
      expect(user.slug).to eq(slug)
    end
  end

  describe "soft delete" do
    it "is properly deleted" do
      user # Used to say to RSpec that we need that record
      user_count_before = User.count
      user.destroy
      expect(User.count).to eq(user_count_before - 1)
    end

    it "is an be found as deleted" do
      user.destroy
      from_db = User.unscoped.find(user.id)
      expect(from_db).not_to be_nil
      expect(from_db.deleted?).to be_truthy
    end
  end
end
