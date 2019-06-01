require 'spec_helper'
require 'pry'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to GearRack!")
    end
  end

  describe "Signup Page" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to gear rack index' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include("/home")
    end

    it 'does not let a user sign up without a name' do
      params = {
          :name => "",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a username' do
      params = {
          :name => "Test User",
          :username => "",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without an email' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "",
          :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'creates a new user and logs them in on valid submission and does not let a logged in user view the signup page' do
      params = {
          :name => "Test User",
          :username => "skittles123",
          :email => "skittles@aol.com",
          :password => "rainbows"
      }
      post '/signup', params
      get '/signup'
      expect(last_response.location).to include('/home')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the gear index after login' do
      user = User.create(:name => "Testing", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to your Gear Rack, #{user.name}")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:name => "Testing", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/login'
      expect(last_response.location).to include("/home")
    end
  end

  describe "logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/logout'
      expect(last_response.location).to include("/login")
    end

    it 'does not let a user logout if not logged in' do
      get '/logout'
      expect(last_response.location).to include("/")
    end

    it 'does not load /home if user not logged in' do
      get '/home'
      expect(last_response.location).to include("/")
    end

    it 'does load /home if user is logged in' do
      user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")


      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      expect(page.current_path).to eq('/home')
    end
  end

  describe 'user show page' do
    it 'shows all a single users gear boxes' do
      user = User.create(:name => "Test", :username => "becky567", :email => "starz@aol.com", :password => "kittens")
      box1 = Box.create(:name => "Snowboarding", :user_id => user.id)
      box2 = Box.create(:name => "Skiing", :user_id => user.id)
      get "/users/#{user.slug}"

      expect(last_response.body).to include("Snowboarding")
      expect(last_response.body).to include("Skiing")

    end
  end

end
