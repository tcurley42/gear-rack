require 'spec_helper'
require 'pry'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to Gear Rack")
    end
  end

  describe "Signup Page" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to gear rack index' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include("/gear")
    end

    it 'does not let a user sign up without a username' do
      params = {
        :username => "",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without an email' do
      params = {
        :username => "skittles123",
        :email => "",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'creates a new user and logs them in on valid submission and does not let a logged in user view the signup page' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      get '/signup'
      expect(last_response.location).to include('/gear')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the gear index after login' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome,")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/login'
      expect(last_response.location).to include("/gear")
    end
  end

  describe "logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

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

    it 'does not load /gear if user not logged in' do
      get '/gear'
      expect(last_response.location).to include("/login")
    end

    it 'does load /gear if user is logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")


      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      expect(page.current_path).to eq('/gear')
    end
  end

  describe 'user show page' do
    it 'shows all a single users gear boxes' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      tweet1 = Tweet.create(:content => "tweeting!", :user_id => user.id)
      tweet2 = Tweet.create(:content => "tweet tweet tweet", :user_id => user.id)
      get "/users/#{user.slug}"

      expect(last_response.body).to include("tweeting!")
      expect(last_response.body).to include("tweet tweet tweet")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view the tweets index if logged in' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/tweets"
        expect(page.body).to include(tweet1.content)
        expect(page.body).to include(tweet2.content)
      end
    end

    context 'logged out' do
      it 'does not let a user view the tweets index if not logged in' do
        get '/tweets'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'new action' do
    context 'logged in' do
      it 'lets user view new box form if logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a box if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/boxes/new'
        fill_in(:sport, :with => "Snowboarding")
        click_button 'submit'

        user = User.find_by(:username => "becky567")
        box = Box.find_by(:content => "Snowboarding")
        expect(box).to be_instance_of(Box)
        expect(box.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user create a box from another user' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/boxes/new'

        fill_in(:sport, :with => "Skiing")
        click_button 'submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        box = Box.find_by(:sport => "Skiing")
        expect(box).to be_instance_of(Box)
        expect(box.user_id).to eq(user.id)
        expect(box.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank box' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/boxes/new'

        fill_in(:sport, :with => "")
        click_button 'submit'

        expect(Box.find_by(:sport => "")).to eq(nil)
        expect(page.current_path).to eq("/boxes/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new box form if not logged in' do
        get '/boxes/new'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single box' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:sport => "Climbing", :user_id => user.id)
        item = Item.create(:name => "Harness", :description => "Orange blah blah harness")
        box.items << item

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/boxes/#{box.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Box")
        expect(page.body).to include(box.sport)
        expect(page.body).to include("Edit Box")
        expect(page.body).to include(item.name)
      end
    end

    context 'logged out' do
      it 'does not let a user view a box' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:sport => "Climbing", :user_id => user.id)
        get "/boxes/#{box.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view box edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:sport => "Skiing", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(box.content)
      end

      it 'does not let a user edit a box they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(:sport => "Climbing", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        box2 = Box.create(:sport => "Skiing", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/boxes/#{box2.id}/edit"
        expect(page.current_path).to include('/boxes')
      end

      it 'lets a user edit their own box if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:sport => "Climbing", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/1/edit'

        fill_in(:sport, :with => "Skiing")

        click_button 'submit'
        expect(Box.find_by(id: box.id, sport: "Skiing")).to be_instance_of(Box)
        expect(Box.find_by(id: box.id, sport: "Climbing")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank sport' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:sport => "Skiing", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/boxes/1/edit'

        fill_in(:sport, :with => "")

        click_button 'submit'
        expect(Box.find(box.id)).to be(nil)
        expect(page.current_path).to eq("/boxes/1/edit")
      end
    end

    context "logged out" do
      it 'does not load -- instead redirects to login' do
        get '/boxes/1/edit'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own box if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box = Box.create(:sport => "Skiing", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'boxes/1'
        click_button "Delete Box"
        expect(page.status_code).to eq(200)
        expect(Box.find(box.id)).to eq(nil)
      end

      it 'does not let a user delete a box they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        box1 = Box.create(:sport => "Skiing", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        box2 = Box.create(:sport => "Snowboarding", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "boxes/#{box2.id}"
        click_button "Delete Box"
        expect(page.status_code).to eq(200)
        expect(Box.find(box2.id)).to be_instance_of(Box)
        expect(page.current_path).to include('/boxes')
      end
    end

    context "logged out" do
      it 'does not load let user delete a box if not logged in' do
        box = Box.create(:sport => "Skiing", :user_id => 1)
        visit '/boxes/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
