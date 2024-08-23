require 'rails_helper'

RSpec.describe User, type: :model do

  it "is not valid without a username" do
    expect(
      User.new(username: nil, name: "1", password: "password")
    ).not_to be_valid
  end

  it "is valid without a name" do
    expect(
      User.new(username: "User 1", name: nil, password: "password")
    ).to be_valid
  end

  it "is not valid without a password" do
    expect(
      User.new(username: "User 1", name: "1",password: nil)
    ).not_to be_valid
  end

  it "is valid with a title, content, user_id" do
    expect(
      User.new(username: "User 1", name: "1",password: "password")
    ).to be_valid
  end

  it "has many Notes" do
    user = User.create(username: "User 1",name: "1", password: "password")

    note_1 = Note.create(
      title: "Title",
      content: "Content",
      user_id: user.id
    )
    note_2 = Note.create(
      title: "Title",
      content: "Content",
      user_id: user.id
    )
    expect(user.notes).to include(note_1, note_2)
  end

  it "is valid with a unique username" do
    User.create(username: "User 1", name: "1", password: "password")
    user = User.new(username: "User 2", name: "2", password: "password")
    expect(user).to be_valid
  end

  it "is not valid with a duplicate username" do
    User.create(username: "User 1", name: "1", password: "password")
    user = User.new(username: "User 1", name: "1", password: "password")
    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("has already been taken")
  end

end