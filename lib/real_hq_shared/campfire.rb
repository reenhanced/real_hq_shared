if Configs[:campfire] && Configs[:campfire][:subdomain] && Configs[:campfire][:user_auth_token]
  require 'rubygems'
  require 'json'
  
  http_client = begin
    require 'httparty'
    true
  rescue MissingSourceFile
    puts "HTTParty gem not installed. Please add it to your application Gemfile to use Campfire."
    false
  end
  
  if http_client
    class Campfire
      include HTTParty

      base_uri   "https://#{Configs[:campfire][:subdomain]}.campfirenow.com"
      basic_auth Configs[:campfire][:user_auth_token], 'x'
      headers    'Content-Type' => 'application/json'

      def self.rooms
        Campfire.get('/rooms.json')["rooms"]
      end

      def self.room(room_id)
        Room.new(room_id)
      end

      def self.user(id)
        Campfire.get("/users/#{id}.json")["user"]
      end
    end

    class Room
      attr_reader :room_id

      def initialize(room_id)
        @room_id = room_id
      end

      def join
        post 'join'
      end

      def leave
        post 'leave'
      end

      def lock
        post 'lock'
      end

      def unlock
        post 'unlock'
      end

      def message(message)
        send_message message
      end

      def paste(paste)
        send_message paste, 'PasteMessage'
      end

      def play_sound(sound)
        send_message sound, 'SoundMessage'
      end

      def transcript
        get('transcript')['messages']
      end

      private

      def send_message(message, type = 'Textmessage')
        post 'speak', :body => {:message => {:body => message, :type => type}}.to_json
      end

      def get(action, options = {})
        Campfire.get room_url_for(action), options
      end

      def post(action, options = {})
        Campfire.post room_url_for(action), options
      end

      def room_url_for(action)
        "/room/#{room_id}/#{action}.json"
      end
    end  
    
  end
end